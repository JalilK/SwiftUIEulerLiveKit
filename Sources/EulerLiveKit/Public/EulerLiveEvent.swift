import Foundation

public enum EulerLiveEvent: Sendable, Equatable, Hashable {
    case roomInfo(RoomInfoEvent)
    case member(MemberEvent)
    case gift(GiftEvent)
    case like(LikeEvent)
    case comment(CommentEvent)
    case follow(FollowEvent)
    case share(ShareEvent)
    case roomUser(RoomUserEvent)
    case liveIntro(LiveIntroEvent)
    case roomMessage(RoomMessageEvent)
    case caption(CaptionEvent)
    case barrage(BarrageEvent)
    case linkMicFanTicket(LinkMicFanTicketEvent)
    case linkMicArmies(LinkMicArmiesEvent)
    case goalUpdate(GoalUpdateEvent)
    case linkMicMethod(LinkMicMethodEvent)
    case inRoomBanner(InRoomBannerEvent)
    case linkLayer(LinkLayerEvent)
    case workerInfo(WorkerInfoEvent)
    case transportConnect(TransportConnectEvent)
    case unknown(eventName: String)

    public var eventName: String {
        switch self {
        case .roomInfo: return "room_info"
        case .member: return "member"
        case .gift: return "gift"
        case .like: return "like"
        case .comment: return "chat"
        case .follow: return "follow"
        case .share: return "share"
        case .roomUser: return "room_user"
        case .liveIntro: return "live_intro"
        case .roomMessage: return "room_message"
        case .caption: return "caption_message"
        case .barrage: return "barrage"
        case .linkMicFanTicket: return "link_mic_fan_ticket_method"
        case .linkMicArmies: return "link_mic_armies"
        case .goalUpdate: return "goal_update"
        case .linkMicMethod: return "link_mic_method"
        case .inRoomBanner: return "in_room_banner"
        case .linkLayer: return "link_layer"
        case .workerInfo: return "worker_info"
        case .transportConnect: return "tiktok.connect"
        case .unknown(let eventName): return eventName
        }
    }

    public var summary: String {
        switch self {
        case .roomInfo(let event):
            return "roomInfo uniqueId=\(event.uniqueId ?? "nil") roomId=\(event.roomId ?? "nil") viewers=\(event.currentViewers.map(String.init) ?? "nil")"
        case .member(let event):
            return "member user=\(event.uniqueId ?? event.nickname ?? "unknown") viewers=\(event.viewerCount.map(String.init) ?? "nil")"
        case .gift(let event):
            return "gift name=\(event.giftName ?? "unknown") user=\(event.uniqueId ?? event.nickname ?? "unknown") repeat=\(event.repeatCount.map(String.init) ?? "nil") combo=\(event.comboCount.map(String.init) ?? "nil")"
        case .like(let event):
            return "like count=\(event.likeCount.map(String.init) ?? "nil") total=\(event.totalLikeCount.map(String.init) ?? "nil") user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .comment(let event):
            return "chat user=\(event.uniqueId ?? event.nickname ?? "unknown") text=\(event.comment ?? "")"
        case .follow(let event):
            return "follow user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .share(let event):
            return "share user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .roomUser(let event):
            return "roomUser viewers=\(event.viewerCount.map(String.init) ?? "nil") topGifter=\(event.topGifterUniqueId ?? event.topGifterNickname ?? "unknown")"
        case .liveIntro(let event):
            return "liveIntro host=\(event.hostNickname ?? event.hostUniqueId ?? "unknown")"
        case .roomMessage(let event):
            return "roomMessage scene=\(event.scene.map(String.init) ?? "nil") text=\(event.displayText ?? event.content ?? "")"
        case .caption(let event):
            return "caption lines=\(event.lines.count) text=\(event.lines.compactMap { $0.content }.joined(separator: " | "))"
        case .barrage(let event):
            return "barrage user=\(event.uniqueId ?? event.nickname ?? "unknown") text=\(event.displayText ?? "")"
        case .linkMicFanTicket(let event):
            return "linkMicFanTicket total=\(event.totalLinkMicFanTicket.map(String.init) ?? "nil") users=\(event.users.count)"
        case .linkMicArmies(let event):
            return "linkMicArmies battle=\(event.battleId ?? "nil") sides=\(event.sides.count) diamonds=\(event.totalDiamondCount.map(String.init) ?? "nil")"
        case .goalUpdate(let event):
            return "goalUpdate goalId=\(event.goalId ?? "nil") contributor=\(event.contributorDisplayId ?? event.contributorId ?? "nil") score=\(event.contributeScore.map(String.init) ?? "nil") subGoals=\(event.subGoals.count)"
        case .linkMicMethod(let event):
            return "linkMicMethod type=\(event.messageType.map(String.init) ?? "nil") totalFanTicket=\(event.totalLinkMicFanTicket.map(String.init) ?? "nil") userId=\(event.userId ?? "nil")"
        case .inRoomBanner(let event):
            return "inRoomBanner currents=\(event.currents.count) playerStates=\(event.playerStates.count)"
        case .linkLayer(let event):
            return "linkLayer scene=\(event.scene.map(String.init) ?? "nil") messageType=\(event.messageType.map(String.init) ?? "nil") participants=\(event.participants.count)"
        case .workerInfo(let event):
            return "workerInfo schema=\(event.schemaVersion ?? "nil") socket=\(event.webSocketId ?? "nil")"
        case .transportConnect(let event):
            return "tiktok.connect agentId=\(event.agentId ?? "nil")"
        case .unknown(let eventName):
            return "unknown event=\(eventName)"
        }
    }

    public var description: String {
        switch self {
        case .roomInfo:
            return EulerDocumentedEventKind.roomInfo.description
        case .member:
            return EulerDocumentedEventKind.member.description
        case .gift:
            return EulerDocumentedEventKind.gift.description
        case .like:
            return EulerDocumentedEventKind.like.description
        case .comment:
            return EulerDocumentedEventKind.chat.description
        case .follow:
            return EulerDocumentedEventKind.follow.description
        case .share:
            return EulerDocumentedEventKind.share.description
        case .roomUser:
            return EulerDocumentedEventKind.roomUser.description
        case .liveIntro:
            return EulerDocumentedEventKind.liveIntro.description
        case .roomMessage:
            return EulerDocumentedEventKind.roomMessage.description
        case .caption:
            return EulerDocumentedEventKind.captionMessage.description
        case .barrage:
            return EulerDocumentedEventKind.barrage.description
        case .linkMicFanTicket:
            return EulerDocumentedEventKind.linkMicFanTicketMethod.description
        case .linkMicArmies:
            return EulerDocumentedEventKind.linkMicArmies.description
        case .goalUpdate:
            return EulerDocumentedEventKind.goalUpdate.description
        case .linkMicMethod:
            return EulerDocumentedEventKind.linkMicMethod.description
        case .inRoomBanner:
            return EulerDocumentedEventKind.inRoomBanner.description
        case .linkLayer:
            return EulerDocumentedEventKind.linkLayer.description
        case .workerInfo:
            return "Worker-side transport metadata."
        case .transportConnect:
            return "Transport connection bootstrap metadata."
        case .unknown:
            return "A live payload that has not been modeled yet."
        }
    }
}
