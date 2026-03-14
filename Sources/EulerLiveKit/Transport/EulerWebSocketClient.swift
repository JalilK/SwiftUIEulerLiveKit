import Foundation

public protocol EulerWebSocketClient: Sendable {
    func connect(to url: URL) async throws
    func receiveText() async throws -> String
    func disconnect(closeCode: Int?) async
}
