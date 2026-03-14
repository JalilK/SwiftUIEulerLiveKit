import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class URLSessionWebSocketClient: NSObject, @unchecked Sendable, EulerWebSocketClient {
    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?

    public override init() {
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
        super.init()
    }

    public func connect(to url: URL) async throws {
        let task = session.webSocketTask(with: url)
        task.resume()
        self.webSocketTask = task
    }

    public func receiveText() async throws -> String {
        guard let webSocketTask else {
            throw EulerLiveError.transportFailure("WebSocket has not been connected.")
        }

        let message = try await webSocketTask.receive()
        switch message {
        case .string(let text):
            return text
        case .data(let data):
            return String(decoding: data, as: UTF8.self)
        @unknown default:
            throw EulerLiveError.transportFailure("Unsupported WebSocket message type.")
        }
    }

    public func disconnect(closeCode: Int?) async {
        guard let webSocketTask else { return }
        if let closeCode, let code = URLSessionWebSocketTask.CloseCode(rawValue: closeCode) {
            webSocketTask.cancel(with: code, reason: nil)
        } else {
            webSocketTask.cancel(with: .normalClosure, reason: nil)
        }
        self.webSocketTask = nil
    }
}
