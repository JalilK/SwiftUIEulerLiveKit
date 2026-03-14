import Foundation

public struct EulerWebSocketCredentials: Sendable, Equatable, Codable {
    public let creator: String?
    public let jwtKey: String
    public let websocketURL: URL
    public let expiresInSeconds: Int?
    public let strategy: String?

    public init(
        creator: String?,
        jwtKey: String,
        websocketURL: URL,
        expiresInSeconds: Int?,
        strategy: String?
    ) {
        self.creator = creator
        self.jwtKey = jwtKey
        self.websocketURL = websocketURL
        self.expiresInSeconds = expiresInSeconds
        self.strategy = strategy
    }
}
