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
    case workerInfo(WorkerInfoEvent)
    case transportConnect(TransportConnectEvent)
    case unknown(eventName: String)

    public var eventName: String {
        switch self {
        case .roomInfo:
            return "room_info"
        case .member:
            return "member"
        case .gift:
            return "gift"
        case .like:
            return "like"
        case .comment:
            return "chat"
        case .follow:
            return "follow"
        case .share:
            return "share"
        case .roomUser:
            return "room_user"
        case .liveIntro:
            return "live_intro"
        case .roomMessage:
            return "room_message"
        case .caption:
            return "caption_message"
        case .barrage:
            return "barrage"
        case .linkMicFanTicket:
            return "link_mic_fan_ticket_method"
        case .workerInfo:
            return "worker_info"
        case .transportConnect:
            return "tiktok.connect"
        case .unknown(let eventName):
            return eventName
        }
    }

    public var summary: String {
        switch self {
        case .roomInfo(let event):
            return "roomInfo uniqueId=\(event.uniqueId ?? "nil") roomId=\(event.roomId ?? "nil") viewers=\(event.currentViewers.map(String.init) ?? "nil")"
        case .member(let event):
            return "member user=\(event.uniqueId ?? event.nickname ?? "unknown") viewers=\(event.viewerCount.map(String.init) ?? "nil")"
        case .gift(let event):
            return "gift name=\(event.giftName ?? "unknown") user=\(event.uniqueId ?? event.nickname ?? "unknown") repeat=\(event.repeatCount.map(String.init) ?? "nil")"
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
        case .workerInfo(let event):
            return "workerInfo schema=\(event.schemaVersion ?? "nil") socket=\(event.webSocketId ?? "nil")"
        case .transportConnect(let event):
            return "tiktok.connect agentId=\(event.agentId ?? "nil")"
        case .unknown(let eventName):
            return "unknown event=\(eventName)"
        }
    }
}
