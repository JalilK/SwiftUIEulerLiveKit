import Foundation

public enum EulerLiveEvent: Sendable, Equatable, Hashable {
    case roomInfo(RoomInfoEvent)
    case join(JoinEvent)
    case gift(GiftEvent)
    case like(LikeEvent)
    case comment(CommentEvent)
    case follow(FollowEvent)
    case share(ShareEvent)
    case unknown(eventName: String)

    public var eventName: String {
        switch self {
        case .roomInfo:
            return "room_info"
        case .join:
            return "join"
        case .gift:
            return "gift"
        case .like:
            return "like"
        case .comment:
            return "comment"
        case .follow:
            return "follow"
        case .share:
            return "share"
        case .unknown(let eventName):
            return eventName
        }
    }

    public var summary: String {
        switch self {
        case .roomInfo(let event):
            return "roomInfo uniqueId=\(event.uniqueId ?? "nil") roomId=\(event.roomId ?? "nil")"
        case .join(let event):
            return "join user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .gift(let event):
            return "gift name=\(event.giftName ?? "unknown") user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .like(let event):
            return "like count=\(event.likeCount.map(String.init) ?? "nil") user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .comment(let event):
            return "comment user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .follow(let event):
            return "follow user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .share(let event):
            return "share user=\(event.uniqueId ?? event.nickname ?? "unknown")"
        case .unknown(let eventName):
            return "unknown event=\(eventName)"
        }
    }
}
