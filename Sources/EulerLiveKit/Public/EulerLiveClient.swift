import Foundation

@MainActor
public final class EulerLiveClient {
    public typealias SocketFactory = @Sendable () -> any EulerWebSocketClient

    public nonisolated let configuration: EulerLiveConfiguration
    public nonisolated let tokenProvider: any EulerTokenProvider

    public var onStatusChange: (@Sendable (EulerConnectionStatus) -> Void)?
    public var onEventRecord: (@Sendable (EulerDebugEventRecord) -> Void)?

    public private(set) var status: EulerConnectionStatus = .idle {
        didSet { onStatusChange?(status) }
    }
    public private(set) var latestEventRecord: EulerDebugEventRecord?
    public private(set) var eventHistory: [EulerDebugEventRecord] = []

    private let session: EulerLiveSession

    public init(
        configuration: EulerLiveConfiguration,
        tokenProvider: any EulerTokenProvider,
        socketFactory: @escaping SocketFactory = { URLSessionWebSocketClient() }
    ) {
        self.configuration = configuration
        self.tokenProvider = tokenProvider
        self.session = EulerLiveSession(
            configuration: configuration,
            tokenProvider: tokenProvider,
            socketFactory: socketFactory
        )
    }

    public func connect(to uniqueId: String) async throws {
        let callbacks = EulerLiveSessionCallbacks(
            onStatusChange: { [weak self] status in
                guard let self else { return }
                Task { @MainActor in
                    self.status = status
                }
            },
            onEventRecord: { [weak self] record in
                guard let self else { return }
                Task { @MainActor in
                    self.latestEventRecord = record
                    self.eventHistory.insert(record, at: 0)
                    if self.eventHistory.count > self.configuration.eventHistoryLimit {
                        self.eventHistory.removeLast(self.eventHistory.count - self.configuration.eventHistoryLimit)
                    }
                    self.onEventRecord?(record)
                }
            }
        )

        try await session.connect(to: uniqueId, callbacks: callbacks)
    }

    public func disconnect() async {
        await session.disconnect()
    }

    public func clearHistory() {
        latestEventRecord = nil
        eventHistory.removeAll()
    }
}
