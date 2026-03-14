import Foundation

struct EulerLiveSessionCallbacks {
    let onStatusChange: @Sendable (EulerConnectionStatus) -> Void
    let onEventRecord: @Sendable (EulerDebugEventRecord) -> Void
}

actor EulerLiveSession {
    typealias SocketFactory = @Sendable () -> any EulerWebSocketClient

    private enum DisconnectIntent {
        case none
        case requestedByClient
    }

    private let configuration: EulerLiveConfiguration
    private let tokenProvider: any EulerTokenProvider
    private let socketFactory: SocketFactory

    private var socket: (any EulerWebSocketClient)?
    private var receiveTask: Task<Void, Never>?
    private var disconnectIntent: DisconnectIntent = .none

    init(
        configuration: EulerLiveConfiguration,
        tokenProvider: any EulerTokenProvider,
        socketFactory: @escaping SocketFactory
    ) {
        self.configuration = configuration
        self.tokenProvider = tokenProvider
        self.socketFactory = socketFactory
    }

    func connect(to uniqueId: String, callbacks: EulerLiveSessionCallbacks) async throws {
        disconnectIntent = .none
        callbacks.onStatusChange(.fetchingToken)
        let credentials = try await tokenProvider.fetchCredentials(for: uniqueId)

        callbacks.onStatusChange(.connecting)
        let socket = socketFactory()
        try await socket.connect(to: credentials.websocketURL)
        self.socket = socket

        let historyLimit = configuration.eventHistoryLimit
        self.receiveTask?.cancel()
        self.receiveTask = Task {
            await self.receiveLoop(socket: socket, callbacks: callbacks, historyLimit: historyLimit)
        }
    }

    func disconnect() async {
        disconnectIntent = .requestedByClient
        receiveTask?.cancel()
        receiveTask = nil
        await socket?.disconnect(closeCode: 1000)
        socket = nil
    }

    private func receiveLoop(
        socket: any EulerWebSocketClient,
        callbacks: EulerLiveSessionCallbacks,
        historyLimit: Int
    ) async {
        _ = historyLimit
        do {
            var hasEmittedConnectedState = false
            while !Task.isCancelled {
                let rawPayload = try await socket.receiveText()
                let record = EulerEventDecoder.decodeRecord(from: rawPayload, receivedAt: Date())
                callbacks.onEventRecord(record)

                if !hasEmittedConnectedState {
                    if case .roomInfo(let roomInfo) = record.decodedTypedEvent {
                        callbacks.onStatusChange(.connected(roomInfo))
                    } else {
                        callbacks.onStatusChange(.connected(nil))
                    }
                    hasEmittedConnectedState = true
                }
            }

            if disconnectIntent == .requestedByClient {
                callbacks.onStatusChange(.disconnected(.requestedByClient))
            }
        } catch is CancellationError {
            callbacks.onStatusChange(.disconnected(disconnectIntent == .requestedByClient ? .requestedByClient : .normalClosure))
        } catch {
            if disconnectIntent == .requestedByClient {
                callbacks.onStatusChange(.disconnected(.requestedByClient))
                return
            }

            let reason: EulerDisconnectReason
            if let liveError = error as? EulerLiveError {
                switch liveError {
                case .disconnected(let mappedReason):
                    reason = mappedReason
                default:
                    reason = .transportError(liveError.description)
                }
            } else {
                reason = .transportError(String(describing: error))
            }
            callbacks.onStatusChange(.disconnected(reason))
        }
    }
}
