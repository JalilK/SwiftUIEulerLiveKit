import Foundation

public struct RoomInfoEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let roomId: String?
    public let nickname: String?
    public let profilePictureURL: String?
    public let title: String?
    public let isLive: Bool?
    public let currentViewers: Int?
    public let totalViewers: Int?

    public init(
        uniqueId: String?,
        roomId: String?,
        nickname: String?,
        profilePictureURL: String?,
        title: String? = nil,
        isLive: Bool? = nil,
        currentViewers: Int? = nil,
        totalViewers: Int? = nil
    ) {
        self.uniqueId = uniqueId
        self.roomId = roomId
        self.nickname = nickname
        self.profilePictureURL = profilePictureURL
        self.title = title
        self.isLive = isLive
        self.currentViewers = currentViewers
        self.totalViewers = totalViewers
    }
}

public struct MemberEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let userId: String?
    public let viewerCount: Int?

    public init(uniqueId: String?, nickname: String?, userId: String? = nil, viewerCount: Int? = nil) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.userId = userId
        self.viewerCount = viewerCount
    }
}

public struct GiftEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let giftName: String?
    public let giftId: Int?
    public let repeatCount: Int?
    public let repeatEnd: Bool?

    public init(
        uniqueId: String?,
        nickname: String?,
        giftName: String?,
        giftId: Int?,
        repeatCount: Int?,
        repeatEnd: Bool? = nil
    ) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.giftName = giftName
        self.giftId = giftId
        self.repeatCount = repeatCount
        self.repeatEnd = repeatEnd
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
    public let userId: String?
    public let comment: String?
    public let isModerator: Bool?
    public let isFollowerOfAnchor: Bool?

    public init(
        uniqueId: String?,
        nickname: String?,
        userId: String? = nil,
        comment: String?,
        isModerator: Bool? = nil,
        isFollowerOfAnchor: Bool? = nil
    ) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.userId = userId
        self.comment = comment
        self.isModerator = isModerator
        self.isFollowerOfAnchor = isFollowerOfAnchor
    }
}

public struct FollowEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let followerCount: Int?

    public init(uniqueId: String?, nickname: String?, followerCount: Int? = nil) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.followerCount = followerCount
    }
}

public struct ShareEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let shareCount: Int?

    public init(uniqueId: String?, nickname: String?, shareCount: Int? = nil) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.shareCount = shareCount
    }
}

public struct RoomUserEvent: Sendable, Equatable, Hashable {
    public let viewerCount: Int?
    public let topGifterUniqueId: String?
    public let topGifterNickname: String?
    public let topGifterCoinCount: Int?

    public init(viewerCount: Int?, topGifterUniqueId: String?, topGifterNickname: String?, topGifterCoinCount: Int?) {
        self.viewerCount = viewerCount
        self.topGifterUniqueId = topGifterUniqueId
        self.topGifterNickname = topGifterNickname
        self.topGifterCoinCount = topGifterCoinCount
    }
}

public struct LiveIntroEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let description: String?
    public let hostUniqueId: String?
    public let hostNickname: String?
    public let hostSecUid: String?

    public init(roomId: String?, description: String?, hostUniqueId: String?, hostNickname: String?, hostSecUid: String?) {
        self.roomId = roomId
        self.description = description
        self.hostUniqueId = hostUniqueId
        self.hostNickname = hostNickname
        self.hostSecUid = hostSecUid
    }
}

public struct RoomMessageEvent: Sendable, Equatable, Hashable {
    public let content: String?
    public let source: String?
    public let scene: Int?
    public let displayText: String?

    public init(content: String?, source: String?, scene: Int?, displayText: String?) {
        self.content = content
        self.source = source
        self.scene = scene
        self.displayText = displayText
    }
}

public struct WorkerInfoEvent: Sendable, Equatable, Hashable {
    public let webSocketId: String?
    public let schemaVersion: String?
    public let isLoggedIn: Bool?
    public let bundleEvents: Bool?
    public let rawMessages: Bool?

    public init(webSocketId: String?, schemaVersion: String?, isLoggedIn: Bool?, bundleEvents: Bool?, rawMessages: Bool?) {
        self.webSocketId = webSocketId
        self.schemaVersion = schemaVersion
        self.isLoggedIn = isLoggedIn
        self.bundleEvents = bundleEvents
        self.rawMessages = rawMessages
    }
}

public struct TransportConnectEvent: Sendable, Equatable, Hashable {
    public let agentId: String?

    public init(agentId: String?) {
        self.agentId = agentId
    }
}

public enum EulerDocumentedEventKind: String, CaseIterable, Sendable {
    case roomInfo = "room_info"
    case member = "member"
    case gift = "gift"
    case like = "like"
    case chat = "chat"
    case follow = "follow"
    case share = "share"
    case roomUser = "room_user"
    case liveIntro = "live_intro"
    case roomMessage = "room_message"

    public var displayName: String { rawValue }
}

public struct EulerDocumentedEventCoverage: Sendable, Equatable {
    public let event: EulerDocumentedEventKind
    public let implemented: Bool
    public let observedRecordCount: Int
    public let observedPayloadTypes: [String]

    public init(event: EulerDocumentedEventKind, implemented: Bool, observedRecordCount: Int, observedPayloadTypes: [String]) {
        self.event = event
        self.implemented = implemented
        self.observedRecordCount = observedRecordCount
        self.observedPayloadTypes = observedPayloadTypes
    }

    public var hasObservedPayload: Bool {
        observedRecordCount > 0
    }
}
