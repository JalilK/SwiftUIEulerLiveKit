import Foundation

public struct EulerLiveConfiguration: Sendable, Equatable {
    public let backendBaseURL: URL
    public let tokenEndpointPath: String
    public let eventHistoryLimit: Int
    public let requestTimeoutSeconds: TimeInterval

    public init(
        backendBaseURL: URL,
        tokenEndpointPath: String = "/token",
        eventHistoryLimit: Int = 250,
        requestTimeoutSeconds: TimeInterval = 30
    ) {
        self.backendBaseURL = backendBaseURL
        self.tokenEndpointPath = tokenEndpointPath
        self.eventHistoryLimit = max(1, eventHistoryLimit)
        self.requestTimeoutSeconds = max(1, requestTimeoutSeconds)
    }

    public var tokenEndpointURL: URL {
        if tokenEndpointPath.hasPrefix("/") {
            return backendBaseURL.appending(path: String(tokenEndpointPath.dropFirst()))
        }
        return backendBaseURL.appending(path: tokenEndpointPath)
    }
}
