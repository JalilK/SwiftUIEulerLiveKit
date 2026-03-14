import Foundation

public enum EulerConnectionStatus: Sendable, Equatable {
    case idle
    case fetchingToken
    case connecting
    case connected(RoomInfoEvent?)
    case disconnected(EulerDisconnectReason)
    case failed(EulerLiveError)
}
