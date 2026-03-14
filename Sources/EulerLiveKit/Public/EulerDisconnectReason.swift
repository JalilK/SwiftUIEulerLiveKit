import Foundation

public enum EulerDisconnectReason: Sendable, Equatable, CustomStringConvertible {
    case requestedByClient
    case normalClosure
    case internalServerError
    case webcastFetchError
    case roomInfoFetchError
    case tiktokClosedConnection
    case tooManyConnections
    case invalidOptions
    case notLive
    case streamEnded
    case noMessagesTimeout
    case invalidAuth
    case noPermission
    case maxLifetimeExceeded
    case serverCode(Int)
    case transportError(String)

    public var description: String {
        switch self {
        case .requestedByClient:
            return "Requested by client"
        case .normalClosure:
            return "Normal closure"
        case .internalServerError:
            return "Internal server error"
        case .webcastFetchError:
            return "Webcast fetch error"
        case .roomInfoFetchError:
            return "Room info fetch error"
        case .tiktokClosedConnection:
            return "TikTok closed connection"
        case .tooManyConnections:
            return "Too many connections"
        case .invalidOptions:
            return "Invalid options"
        case .notLive:
            return "Creator is not live"
        case .streamEnded:
            return "Stream ended"
        case .noMessagesTimeout:
            return "No messages timeout"
        case .invalidAuth:
            return "Invalid auth"
        case .noPermission:
            return "No permission"
        case .maxLifetimeExceeded:
            return "Max lifetime exceeded"
        case .serverCode(let code):
            return "Server code \(code)"
        case .transportError(let message):
            return "Transport error: \(message)"
        }
    }
}
