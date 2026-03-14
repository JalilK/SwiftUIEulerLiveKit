import Foundation

public struct RoomInfoEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let roomId: String?
    public let nickname: String?
    public let profilePictureURL: String?

    public init(uniqueId: String?, roomId: String?, nickname: String?, profilePictureURL: String?) {
        self.uniqueId = uniqueId
        self.roomId = roomId
        self.nickname = nickname
        self.profilePictureURL = profilePictureURL
    }
}

public struct JoinEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?

    public init(uniqueId: String?, nickname: String?) {
        self.uniqueId = uniqueId
        self.nickname = nickname
    }
}

public struct GiftEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let giftName: String?
    public let giftId: Int?
    public let repeatCount: Int?

    public init(uniqueId: String?, nickname: String?, giftName: String?, giftId: Int?, repeatCount: Int?) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.giftName = giftName
        self.giftId = giftId
        self.repeatCount = repeatCount
    }
}

public struct LikeEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let likeCount: Int?
    public let totalLikeCount: Int?

    public init(uniqueId: String?, nickname: String?, likeCount: Int?, totalLikeCount: Int?) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.likeCount = likeCount
        self.totalLikeCount = totalLikeCount
    }
}

public struct CommentEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let comment: String?

    public init(uniqueId: String?, nickname: String?, comment: String?) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.comment = comment
    }
}

public struct FollowEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?

    public init(uniqueId: String?, nickname: String?) {
        self.uniqueId = uniqueId
        self.nickname = nickname
    }
}

public struct ShareEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?

    public init(uniqueId: String?, nickname: String?) {
        self.uniqueId = uniqueId
        self.nickname = nickname
    }
}
