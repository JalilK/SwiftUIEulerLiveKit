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

public struct GoalContributor: Sendable, Equatable, Hashable {
    public let userId: String?
    public let userIdStr: String?
    public let displayId: String?
    public let score: Int?
    public let inRoom: Bool?
    public let isFriend: Bool?

    public init(
        userId: String?,
        userIdStr: String?,
        displayId: String?,
        score: Int?,
        inRoom: Bool?,
        isFriend: Bool?
    ) {
        self.userId = userId
        self.userIdStr = userIdStr
        self.displayId = displayId
        self.score = score
        self.inRoom = inRoom
        self.isFriend = isFriend
    }
}

public struct GoalSubGoal: Sendable, Equatable, Hashable {
    public let id: String?
    public let idStr: String?
    public let target: Int?
    public let progress: Int?
    public let source: Int?
    public let type: Int?
    public let giftName: String?
    public let giftDiamondCount: Int?

    public init(
        id: String?,
        idStr: String?,
        target: Int?,
        progress: Int?,
        source: Int?,
        type: Int?,
        giftName: String?,
        giftDiamondCount: Int?
    ) {
        self.id = id
        self.idStr = idStr
        self.target = target
        self.progress = progress
        self.source = source
        self.type = type
        self.giftName = giftName
        self.giftDiamondCount = giftDiamondCount
    }
}

public struct GoalUpdateEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let goalId: String?
    public let goalDescription: String?
    public let goalType: Int?
    public let goalStatus: Int?
    public let indicatorKey: String?
    public let indicatorOperation: Int?
    public let updateSource: Int?
    public let contributorId: String?
    public let contributorIdStr: String?
    public let contributorDisplayId: String?
    public let contributeScore: Int?
    public let contributeCount: Int?
    public let pin: Bool?
    public let unpin: Bool?
    public let subGoals: [GoalSubGoal]
    public let contributors: [GoalContributor]

    public init(
        roomId: String?,
        goalId: String?,
        goalDescription: String?,
        goalType: Int?,
        goalStatus: Int?,
        indicatorKey: String?,
        indicatorOperation: Int?,
        updateSource: Int?,
        contributorId: String?,
        contributorIdStr: String?,
        contributorDisplayId: String?,
        contributeScore: Int?,
        contributeCount: Int?,
        pin: Bool?,
        unpin: Bool?,
        subGoals: [GoalSubGoal],
        contributors: [GoalContributor]
    ) {
        self.roomId = roomId
        self.goalId = goalId
        self.goalDescription = goalDescription
        self.goalType = goalType
        self.goalStatus = goalStatus
        self.indicatorKey = indicatorKey
        self.indicatorOperation = indicatorOperation
        self.updateSource = updateSource
        self.contributorId = contributorId
        self.contributorIdStr = contributorIdStr
        self.contributorDisplayId = contributorDisplayId
        self.contributeScore = contributeScore
        self.contributeCount = contributeCount
        self.pin = pin
        self.unpin = unpin
        self.subGoals = subGoals
        self.contributors = contributors
    }
}

public struct LinkMicMethodEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let messageType: Int?
    public let userId: String?
    public let fanTicket: Int?
    public let totalLinkMicFanTicket: Int?
    public let channelId: String?
    public let anchorLinkMicId: String?
    public let rivalAnchorId: String?
    public let matchType: Int?
    public let win: Bool?
    public let shouldShowPopup: Bool?
    public let rtcJoinChannel: Bool?

    public init(
        roomId: String?,
        messageType: Int?,
        userId: String?,
        fanTicket: Int?,
        totalLinkMicFanTicket: Int?,
        channelId: String?,
        anchorLinkMicId: String?,
        rivalAnchorId: String?,
        matchType: Int?,
        win: Bool?,
        shouldShowPopup: Bool?,
        rtcJoinChannel: Bool?
    ) {
        self.roomId = roomId
        self.messageType = messageType
        self.userId = userId
        self.fanTicket = fanTicket
        self.totalLinkMicFanTicket = totalLinkMicFanTicket
        self.channelId = channelId
        self.anchorLinkMicId = anchorLinkMicId
        self.rivalAnchorId = rivalAnchorId
        self.matchType = matchType
        self.win = win
        self.shouldShowPopup = shouldShowPopup
        self.rtcJoinChannel = rtcJoinChannel
    }
}

public struct InRoomBannerLeadContributor: Sendable, Equatable, Hashable {
    public let rank: Int?
    public let score: Int?
    public let uid: String?

    public init(rank: Int?, score: Int?, uid: String?) {
        self.rank = rank
        self.score = score
        self.uid = uid
    }
}

public struct InRoomBannerPlayerState: Sendable, Equatable, Hashable {
    public let activityCode: String?
    public let featureName: String?
    public let rank: Int?
    public let score: Int?
    public let stateId: String?
    public let uid: String?
    public let targetRank: Int?
    public let targetScore: Int?
    public let leadContributors: [InRoomBannerLeadContributor]

    public init(
        activityCode: String?,
        featureName: String?,
        rank: Int?,
        score: Int?,
        stateId: String?,
        uid: String?,
        targetRank: Int?,
        targetScore: Int?,
        leadContributors: [InRoomBannerLeadContributor]
    ) {
        self.activityCode = activityCode
        self.featureName = featureName
        self.rank = rank
        self.score = score
        self.stateId = stateId
        self.uid = uid
        self.targetRank = targetRank
        self.targetScore = targetScore
        self.leadContributors = leadContributors
    }
}

public struct InRoomBannerCurrent: Sendable, Equatable, Hashable {
    public let activityCode: String?
    public let now: Int?
    public let phaseName: String?

    public init(activityCode: String?, now: Int?, phaseName: String?) {
        self.activityCode = activityCode
        self.now = now
        self.phaseName = phaseName
    }
}

public struct InRoomBannerEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let position: Int?
    public let actionType: Int?
    public let currents: [InRoomBannerCurrent]
    public let playerStates: [InRoomBannerPlayerState]

    public init(
        roomId: String?,
        position: Int?,
        actionType: Int?,
        currents: [InRoomBannerCurrent],
        playerStates: [InRoomBannerPlayerState]
    ) {
        self.roomId = roomId
        self.position = position
        self.actionType = actionType
        self.currents = currents
        self.playerStates = playerStates
    }
}

public struct LinkLayerParticipant: Sendable, Equatable, Hashable {
    public let channelId: String?
    public let userId: String?
    public let displayId: String?
    public let nickname: String?
    public let status: Int?
    public let type: Int?
    public let joinTime: String?

    public init(
        channelId: String?,
        userId: String?,
        displayId: String?,
        nickname: String?,
        status: Int?,
        type: Int?,
        joinTime: String?
    ) {
        self.channelId = channelId
        self.userId = userId
        self.displayId = displayId
        self.nickname = nickname
        self.status = status
        self.type = type
        self.joinTime = joinTime
    }
}

public struct LinkLayerEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let scene: Int?
    public let messageType: Int?
    public let channelId: String?
    public let source: String?
    public let rtcRoomId: String?
    public let participants: [LinkLayerParticipant]

    public init(
        roomId: String?,
        scene: Int?,
        messageType: Int?,
        channelId: String?,
        source: String?,
        rtcRoomId: String?,
        participants: [LinkLayerParticipant]
    ) {
        self.roomId = roomId
        self.scene = scene
        self.messageType = messageType
        self.channelId = channelId
        self.source = source
        self.rtcRoomId = rtcRoomId
        self.participants = participants
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


public struct SocialRepostEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let userId: String?
    public let uniqueId: String?
    public let nickname: String?
    public let action: Int?
    public let shareType: Int?
    public let shareCount: Int?
    public let displayText: String?

    public init(
        roomId: String?,
        userId: String?,
        uniqueId: String?,
        nickname: String?,
        action: Int?,
        shareType: Int?,
        shareCount: Int?,
        displayText: String?
    ) {
        self.roomId = roomId
        self.userId = userId
        self.uniqueId = uniqueId
        self.nickname = nickname
        self.action = action
        self.shareType = shareType
        self.shareCount = shareCount
        self.displayText = displayText
    }
}

public struct LinkMicBattleEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let battleId: String?
    public let channelId: String?
    public let status: Int?
    public let action: Int?
    public let inviteType: Int?
    public let duration: Int?
    public let battleType: Int?
    public let startTimeMs: String?
    public let endTimeMs: String?
    public let actionByUserId: String?
    public let leftUserId: String?
    public let leftDisplayId: String?
    public let leftNickname: String?
    public let rightUserId: String?
    public let rightDisplayId: String?
    public let rightNickname: String?
    public let leftScore: Int?
    public let rightScore: Int?
    public let leftResult: Int?
    public let rightResult: Int?
    public let leftComboCount: Int?
    public let rightComboCount: Int?

    public init(
        roomId: String?,
        battleId: String?,
        channelId: String?,
        status: Int?,
        action: Int?,
        inviteType: Int?,
        duration: Int?,
        battleType: Int?,
        startTimeMs: String?,
        endTimeMs: String?,
        actionByUserId: String?,
        leftUserId: String?,
        leftDisplayId: String?,
        leftNickname: String?,
        rightUserId: String?,
        rightDisplayId: String?,
        rightNickname: String?,
        leftScore: Int?,
        rightScore: Int?,
        leftResult: Int?,
        rightResult: Int?,
        leftComboCount: Int?,
        rightComboCount: Int?
    ) {
        self.roomId = roomId
        self.battleId = battleId
        self.channelId = channelId
        self.status = status
        self.action = action
        self.inviteType = inviteType
        self.duration = duration
        self.battleType = battleType
        self.startTimeMs = startTimeMs
        self.endTimeMs = endTimeMs
        self.actionByUserId = actionByUserId
        self.leftUserId = leftUserId
        self.leftDisplayId = leftDisplayId
        self.leftNickname = leftNickname
        self.rightUserId = rightUserId
        self.rightDisplayId = rightDisplayId
        self.rightNickname = rightNickname
        self.leftScore = leftScore
        self.rightScore = rightScore
        self.leftResult = leftResult
        self.rightResult = rightResult
        self.leftComboCount = leftComboCount
        self.rightComboCount = rightComboCount
    }
}

public struct LinkMicBattleTaskEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let battleId: String?
    public let messageType: Int?
    public let taskProgress: Int?
    public let fromUserUid: String?
    public let taskResult: Int?
    public let rewardStartTimestamp: String?
    public let rewardStartTime: Int?
    public let rewardMultiple: Int?
    public let rewardSettleAmount: Int?
    public let rewardStatus: Int?
    public let progressTarget: Int?

    public init(
        roomId: String?,
        battleId: String?,
        messageType: Int?,
        taskProgress: Int?,
        fromUserUid: String?,
        taskResult: Int?,
        rewardStartTimestamp: String?,
        rewardStartTime: Int?,
        rewardMultiple: Int?,
        rewardSettleAmount: Int?,
        rewardStatus: Int?,
        progressTarget: Int?
    ) {
        self.roomId = roomId
        self.battleId = battleId
        self.messageType = messageType
        self.taskProgress = taskProgress
        self.fromUserUid = fromUserUid
        self.taskResult = taskResult
        self.rewardStartTimestamp = rewardStartTimestamp
        self.rewardStartTime = rewardStartTime
        self.rewardMultiple = rewardMultiple
        self.rewardSettleAmount = rewardSettleAmount
        self.rewardStatus = rewardStatus
        self.progressTarget = progressTarget
    }
}

public struct UnauthorizedMemberEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let nickname: String?
    public let action: Int?
    public let enterText: String?

    public init(roomId: String?, nickname: String?, action: Int?, enterText: String?) {
        self.roomId = roomId
        self.nickname = nickname
        self.action = action
        self.enterText = enterText
    }
}

public struct ModerationDeleteEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let deletedUserIds: [String]
    public let deletedMessageIds: [String]

    public init(roomId: String?, deletedUserIds: [String], deletedMessageIds: [String]) {
        self.roomId = roomId
        self.deletedUserIds = deletedUserIds
        self.deletedMessageIds = deletedMessageIds
    }
}

public struct LinkMicBattlePunishFinishEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let battleId: String?
    public let channelId: String?
    public let operatorUserId: String?
    public let reason: Int?
    public let status: Int?
    public let endTimeMs: String?

    public init(
        roomId: String?,
        battleId: String?,
        channelId: String?,
        operatorUserId: String?,
        reason: Int?,
        status: Int?,
        endTimeMs: String?
    ) {
        self.roomId = roomId
        self.battleId = battleId
        self.channelId = channelId
        self.operatorUserId = operatorUserId
        self.reason = reason
        self.status = status
        self.endTimeMs = endTimeMs
    }
}

public struct LinkMessageEvent: Sendable, Equatable, Hashable {
    public let roomId: String?
    public let scene: Int?
    public let linkerId: String?
    public let messageType: Int?
    public let expireTimestamp: String?
    public let extra: String?
    public let transferExtra: String?

    public init(
        roomId: String?,
        scene: Int?,
        linkerId: String?,
        messageType: Int?,
        expireTimestamp: String?,
        extra: String?,
        transferExtra: String?
    ) {
        self.roomId = roomId
        self.scene = scene
        self.linkerId = linkerId
        self.messageType = messageType
        self.expireTimestamp = expireTimestamp
        self.extra = extra
        self.transferExtra = transferExtra
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
    case goalUpdate = "goal_update"
    case linkMicMethod = "link_mic_method"
    case inRoomBanner = "in_room_banner"
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
        case .goalUpdate: return "Goal update"
        case .linkMicMethod: return "LinkMic method"
        case .inRoomBanner: return "In-room banner"
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
        case .goalUpdate:
            return "Live goal progress, contributors, subgoals, and pin state."
        case .linkMicMethod:
            return "LinkMic score and match-state summary updates."
        case .inRoomBanner:
            return "In-room ranking and activity banner payloads."
        case .linkLayer:
            return "Cohost and link-layer participant graph updates."
        }
    }

    public var implemented: Bool {
        true
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
