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

    public var userFacingTitle: String {
        switch self {
        case .requestedByClient, .normalClosure:
            return "Disconnected"
        case .notLive:
            return "Creator is not live"
        case .tooManyConnections:
            return "Connection limit reached"
        case .invalidAuth, .noPermission:
            return "Authorization failed"
        case .streamEnded:
            return "Stream ended"
        default:
            return "Connection ended"
        }
    }

    public var userFacingMessage: String {
        switch self {
        case .requestedByClient:
            return "You disconnected from the stream."
        case .normalClosure:
            return "The connection closed normally."
        case .notLive:
            return "That creator is not live right now."
        case .tooManyConnections:
            return "Euler rejected the connection because too many sockets are open or reconnects happened too quickly."
        case .invalidAuth:
            return "The worker returned credentials that Euler did not accept."
        case .noPermission:
            return "The JWT key does not have access to that creator."
        case .streamEnded:
            return "The creator ended the stream."
        case .transportError:
            return "The socket closed unexpectedly. Open Technical Details if you need the raw transport error."
        default:
            return description
        }
    }

    public var isExpectedUserAction: Bool {
        switch self {
        case .requestedByClient, .normalClosure:
            return true
        default:
            return false
        }
    }
}
