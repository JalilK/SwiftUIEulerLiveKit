import Foundation

public enum EulerConnectionState: Equatable, Sendable {
    case idle
    case connecting
    case connected
    case disconnecting
    case disconnected(DisconnectReason)
    case failed(String)
}

public enum DisconnectReason: Equatable, Sendable {
    case userInitiated
    case creatorOffline
    case connectionClosed
    case networkIssue
    case unknown
}

extension NSError {
    static func userFriendlyMessage(from error: Error) -> String {
        let ns = error as NSError

        if ns.domain == NSPOSIXErrorDomain && ns.code == 57 {
            return "stream disconnected"
        }

        if ns.domain == NSURLErrorDomain {
            switch ns.code {
            case NSURLErrorNotConnectedToInternet:
                return "no internet connection"
            case NSURLErrorTimedOut:
                return "connection timed out"
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                return "unable to reach stream"
            default:
                break
            }
        }

        return "connection failed"
    }
}
