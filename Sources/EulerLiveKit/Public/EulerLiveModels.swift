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
    public let giftType: Int?
    public let displayText: String?
    public let groupId: String?
    public let comboCount: Int?
    public let diamondCount: Int?

    public init(
        uniqueId: String?,
        nickname: String?,
        giftName: String?,
        giftId: Int?,
        repeatCount: Int?,
        repeatEnd: Bool? = nil,
        giftType: Int? = nil,
        displayText: String? = nil,
        groupId: String? = nil,
        comboCount: Int? = nil,
        diamondCount: Int? = nil
    ) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.giftName = giftName
        self.giftId = giftId
        self.repeatCount = repeatCount
        self.repeatEnd = repeatEnd
        self.giftType = giftType
        self.displayText = displayText
        self.groupId = groupId
        self.comboCount = comboCount
        self.diamondCount = diamondCount
    }
}

public struct LikeEvent: Sendable, Equatable, Hashable {
    public let uniqueId: String?
    public let nickname: String?
    public let likeCount: Int?
    public let totalLikeCount: Int?
    public let displayText: String?

    public init(uniqueId: String?, nickname: String?, likeCount: Int?, totalLikeCount: Int?, displayText: String? = nil) {
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.likeCount = likeCount
        self.totalLikeCount = totalLikeCount
        self.displayText = displayText
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

public struct CaptionLine: Sendable, Equatable, Hashable {
    public let language: String?
    public let content: String?

    public init(language: String?, content: String?) {
        self.language = language
        self.content = content
    }
}

public struct CaptionEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let timestampMs: Int?
    public let durationMs: Int?
    public let sentenceId: String?
    public let sequenceId: String?
    public let definite: Bool?
    public let lines: [CaptionLine]

    public init(
        roomId: String?,
        timestampMs: Int?,
        durationMs: Int?,
        sentenceId: String?,
        sequenceId: String?,
        definite: Bool?,
        lines: [CaptionLine]
    ) {
        self.roomId = roomId
        self.timestampMs = timestampMs
        self.durationMs = durationMs
        self.sentenceId = sentenceId
        self.sequenceId = sequenceId
        self.definite = definite
        self.lines = lines
    }
}

public struct BarrageEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let messageType: Int?
    public let durationMs: Int?
    public let displayText: String?
    public let userId: String?
    public let uniqueId: String?
    public let nickname: String?

    public init(
        roomId: String?,
        messageType: Int?,
        durationMs: Int?,
        displayText: String?,
        userId: String?,
        uniqueId: String?,
        nickname: String?
    ) {
        self.roomId = roomId
        self.messageType = messageType
        self.durationMs = durationMs
        self.displayText = displayText
        self.userId = userId
        self.uniqueId = uniqueId
        self.nickname = nickname
    }
}

public struct LinkMicFanTicketUser: Sendable, Equatable, Hashable {
    public let userId: String?
    public let fanTicket: Int?
    public let matchTotalScore: Int?
    public let matchRank: Int?

    public init(userId: String?, fanTicket: Int?, matchTotalScore: Int?, matchRank: Int?) {
        self.userId = userId
        self.fanTicket = fanTicket
        self.matchTotalScore = matchTotalScore
        self.matchRank = matchRank
    }
}

public struct LinkMicFanTicketEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let totalLinkMicFanTicket: Int?
    public let matchId: String?
    public let eventTime: Int?
    public let playId: String?
    public let playScene: Int?
    public let users: [LinkMicFanTicketUser]

    public init(
        roomId: String?,
        totalLinkMicFanTicket: Int?,
        matchId: String?,
        eventTime: Int?,
        playId: String?,
        playScene: Int?,
        users: [LinkMicFanTicketUser]
    ) {
        self.roomId = roomId
        self.totalLinkMicFanTicket = totalLinkMicFanTicket
        self.matchId = matchId
        self.eventTime = eventTime
        self.playId = playId
        self.playScene = playScene
        self.users = users
    }
}

public struct LinkMicArmyUser: Sendable, Equatable, Hashable {
    public let userId: String?
    public let userIdStr: String?
    public let nickname: String?
    public let score: Int?
    public let diamondScore: Int?

    public init(userId: String?, userIdStr: String?, nickname: String?, score: Int?, diamondScore: Int?) {
        self.userId = userId
        self.userIdStr = userIdStr
        self.nickname = nickname
        self.score = score
        self.diamondScore = diamondScore
    }
}

public struct LinkMicArmySide: Sendable, Equatable, Hashable {
    public let anchorId: String
    public let hostScore: Int?
    public let users: [LinkMicArmyUser]

    public init(anchorId: String, hostScore: Int?, users: [LinkMicArmyUser]) {
        self.anchorId = anchorId
        self.hostScore = hostScore
        self.users = users
    }
}

public struct LinkMicArmiesEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let battleId: String?
    public let channelId: String?
    public let battleStatus: Int?
    public let giftId: Int?
    public let giftCount: Int?
    public let repeatCount: Int?
    public let totalDiamondCount: Int?
    public let fromUserId: String?
    public let scoreUpdateTime: Int?
    public let giftSentTime: Int?
    public let sides: [LinkMicArmySide]

    public init(
        roomId: String?,
        battleId: String?,
        channelId: String?,
        battleStatus: Int?,
        giftId: Int?,
        giftCount: Int?,
        repeatCount: Int?,
        totalDiamondCount: Int?,
        fromUserId: String?,
        scoreUpdateTime: Int?,
        giftSentTime: Int?,
        sides: [LinkMicArmySide]
    ) {
        self.roomId = roomId
        self.battleId = battleId
        self.channelId = channelId
        self.battleStatus = battleStatus
        self.giftId = giftId
        self.giftCount = giftCount
        self.repeatCount = repeatCount
        self.totalDiamondCount = totalDiamondCount
        self.fromUserId = fromUserId
        self.scoreUpdateTime = scoreUpdateTime
        self.giftSentTime = giftSentTime
        self.sides = sides
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
    case captionMessage = "caption_message"
    case barrage = "barrage"
    case linkMicFanTicketMethod = "link_mic_fan_ticket_method"
    case linkMicArmies = "link_mic_armies"
    case linkLayer = "link_layer"

    public var displayName: String {
        rawValue
    }

    public var title: String {
        switch self {
        case .roomInfo: return "Room info"
        case .member: return "Member"
        case .gift: return "Gift"
        case .like: return "Like"
        case .chat: return "Chat"
        case .follow: return "Follow"
        case .share: return "Share"
        case .roomUser: return "Room user"
        case .liveIntro: return "Live intro"
        case .roomMessage: return "Room message"
        case .captionMessage: return "Caption message"
        case .barrage: return "Barrage"
        case .linkMicFanTicketMethod: return "LinkMic fan ticket"
        case .linkMicArmies: return "LinkMic armies"
        case .linkLayer: return "Link layer"
        }
    }

    public var description: String {
        switch self {
        case .roomInfo:
            return "Creator and room metadata announced when a live connection becomes usable."
        case .member:
            return "A viewer entered the room. This maps to join style activity."
        case .gift:
            return "A viewer sent a gift. This maps to TikTok gifting, streaks, combos, and gift identity."
        case .like:
            return "A viewer liked the live. This maps to TikTok LIVE like and total-like updates."
        case .chat:
            return "A viewer sent a chat message."
        case .follow:
            return "A viewer followed the creator. This is derived from TikTok social activity."
        case .share:
            return "A viewer shared the live. This is derived from TikTok social activity."
        case .roomUser:
            return "Room-level audience and ranking update such as viewer count and top gifters."
        case .liveIntro:
            return "Introductory metadata about the current live session and host."
        case .roomMessage:
            return "System-style room notice such as filtered-comment notices, fan-club notices, or other room level banners."
        case .captionMessage:
            return "Live captions or speech transcription lines generated during the stream."
        case .barrage:
            return "Animated or high-visibility overlay style message, often tied to badges, privilege banners, or entrance effects."
        case .linkMicFanTicketMethod:
            return "Battle and LinkMic fan-ticket score notice for the current battle session."
        case .linkMicArmies:
            return "Battle army scoreboard snapshot containing both sides, supporter ranks, and host scores."
        case .linkLayer:
            return "Battle and co-host session plumbing. This still needs more live capture before public modeling is reliable."
        }
    }

    public var implemented: Bool {
        switch self {
        case .linkLayer:
            return false
        default:
            return true
        }
    }
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
