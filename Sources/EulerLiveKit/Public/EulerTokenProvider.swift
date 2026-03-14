import Foundation

public protocol EulerTokenProvider: Sendable {
    func fetchCredentials(for uniqueId: String) async throws -> EulerWebSocketCredentials
}
