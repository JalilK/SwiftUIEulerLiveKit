import Foundation

enum EulerCloseCodeMapper {
    static func map(_ code: Int?) -> EulerDisconnectReason {
        guard let code else {
            return .transportError("Unknown close reason")
        }

        switch code {
        case 1000:
            return .normalClosure
        case 1011:
            return .internalServerError
        case 4556:
            return .webcastFetchError
        case 4557:
            return .roomInfoFetchError
        case 4500:
            return .tiktokClosedConnection
        case 4429:
            return .tooManyConnections
        case 4400:
            return .invalidOptions
        case 4404:
            return .notLive
        case 4005:
            return .streamEnded
        case 4006:
            return .noMessagesTimeout
        case 4401:
            return .invalidAuth
        case 4403:
            return .noPermission
        case 4555:
            return .maxLifetimeExceeded
        default:
            return .serverCode(code)
        }
    }
}
