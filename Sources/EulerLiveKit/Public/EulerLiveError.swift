import Foundation

public enum EulerLiveError: Error, Sendable, Equatable, CustomStringConvertible {
    case invalidBackendResponse
    case invalidWebSocketURL
    case invalidPayload
    case transportFailure(String)
    case tokenRequestFailed(Int)
    case disconnected(EulerDisconnectReason)

    public var description: String {
        switch self {
        case .invalidBackendResponse:
            return "The backend token response was invalid."
        case .invalidWebSocketURL:
            return "The backend returned an invalid WebSocket URL."
        case .invalidPayload:
            return "The WebSocket payload could not be processed."
        case .transportFailure(let message):
            return "Transport failure: \(message)"
        case .tokenRequestFailed(let statusCode):
            return "Token request failed with status code \(statusCode)."
        case .disconnected(let reason):
            return "Disconnected: \(reason.description)"
        }
    }
}
