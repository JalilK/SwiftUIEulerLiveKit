import Foundation

enum EulerEventDecoder {
    static func decodeRecord(from rawPayload: String, receivedAt: Date = Date()) -> EulerDebugEventRecord {
        guard let data = rawPayload.data(using: .utf8) else {
            return EulerDebugEventRecord(
                eventName: "invalid_payload",
                rawPayload: rawPayload,
                decodedTypedEvent: nil,
                decodeOutcome: .invalidJSON,
                receivedAt: receivedAt
            )
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return EulerDebugEventRecord(
                eventName: "invalid_payload",
                rawPayload: rawPayload,
                decodedTypedEvent: nil,
                decodeOutcome: .invalidJSON,
                receivedAt: receivedAt
            )
        }

        guard let object = json as? [String: Any] else {
            return EulerDebugEventRecord(
                eventName: "unsupported_payload",
                rawPayload: rawPayload,
                decodedTypedEvent: nil,
                decodeOutcome: .unsupportedPayload,
                receivedAt: receivedAt
            )
        }

        let eventName = normalizedEventName(from: object)
        let typedEvent = typedEvent(for: eventName, payload: object)
        let outcome = decodeOutcome(for: eventName, typedEvent: typedEvent)

        return EulerDebugEventRecord(
            eventName: eventName,
            rawPayload: rawPayload,
            decodedTypedEvent: typedEvent,
            decodeOutcome: outcome,
            receivedAt: receivedAt
        )
    }

    private static func decodeOutcome(for eventName: String, typedEvent: EulerLiveEvent?) -> EulerDecodeOutcome {
        guard let typedEvent else {
            return .unknownEvent
        }

        switch typedEvent {
        case .unknown:
            return .unknownEvent
        case .roomInfo(let event):
            let fields = [event.uniqueId, event.roomId, event.nickname, event.profilePictureURL].compactMap { $0 }
            return fields.count >= 2 ? .decoded : .decodedWithPartialData
        case .join(let event):
            let fields = [event.uniqueId, event.nickname].compactMap { $0 }
            return fields.isEmpty ? .decodedWithPartialData : .decoded
        case .gift(let event):
            let hasStrongData = event.giftName != nil || event.giftId != nil || event.uniqueId != nil || event.nickname != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .like(let event):
            let hasStrongData = event.likeCount != nil || event.totalLikeCount != nil || event.uniqueId != nil || event.nickname != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .comment(let event):
            let hasStrongData = event.comment != nil || event.uniqueId != nil || event.nickname != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .follow(let event):
            let hasStrongData = event.uniqueId != nil || event.nickname != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .share(let event):
            let hasStrongData = event.uniqueId != nil || event.nickname != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        }
    }

    private static func normalizedEventName(from object: [String: Any]) -> String {
        if let candidate = findString(in: object, matchingAnyOf: ["eventName", "event_name", "event", "type", "name", "messageType", "msgType"]) {
            return canonicalEventName(candidate)
        }

        if findString(in: object, matchingAnyOf: ["roomId", "room_id"]) != nil {
            return "room_info"
        }

        return "unknown"
    }

    private static func canonicalEventName(_ value: String) -> String {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        switch normalized {
        case "roominfo", "room_info", "room":
            return "room_info"
        case "member", "member_join", "join", "connected_user", "enter", "enter_room":
            return "join"
        case "gift", "gift_event":
            return "gift"
        case "like", "like_event":
            return "like"
        case "comment", "chat", "chat_message", "comment_event":
            return "comment"
        case "follow", "follow_event":
            return "follow"
        case "share", "share_event":
            return "share"
        default:
            return normalized
        }
    }

    private static func typedEvent(for eventName: String, payload: [String: Any]) -> EulerLiveEvent? {
        switch eventName {
        case "room_info":
            return .roomInfo(
                RoomInfoEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "ownerUniqueId", "secUid"]),
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    profilePictureURL: findString(in: payload, matchingAnyOf: ["profilePictureUrl", "profilePictureURL", "avatarThumb", "avatarUrl"])
                )
            )
        case "join":
            return .join(
                JoinEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "secUid"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"])
                )
            )
        case "gift":
            return .gift(
                GiftEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "secUid"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    giftName: findString(in: payload, matchingAnyOf: ["giftName", "gift_name", "name"]),
                    giftId: findInt(in: payload, matchingAnyOf: ["giftId", "gift_id", "id"]),
                    repeatCount: findInt(in: payload, matchingAnyOf: ["repeatCount", "repeat_count", "count"])
                )
            )
        case "like":
            return .like(
                LikeEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "secUid"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    likeCount: findInt(in: payload, matchingAnyOf: ["likeCount", "like_count", "count"]),
                    totalLikeCount: findInt(in: payload, matchingAnyOf: ["totalLikeCount", "total_like_count", "totalCount"])
                )
            )
        case "comment":
            return .comment(
                CommentEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "secUid"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    comment: findString(in: payload, matchingAnyOf: ["comment", "text", "message"])
                )
            )
        case "follow":
            return .follow(
                FollowEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "secUid"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"])
                )
            )
        case "share":
            return .share(
                ShareEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "secUid"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"])
                )
            )
        case "unknown":
            return nil
        default:
            return .unknown(eventName: eventName)
        }
    }

    private static func findString(in value: Any, matchingAnyOf keys: [String]) -> String? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let direct = object[key] {
                    if let string = direct as? String, !string.isEmpty {
                        return string
                    }
                    if let number = direct as? NSNumber {
                        return number.stringValue
                    }
                }
            }

            for child in object.values {
                if let string = findString(in: child, matchingAnyOf: keys) {
                    return string
                }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let string = findString(in: item, matchingAnyOf: keys) {
                    return string
                }
            }
        }

        return nil
    }

    private static func findInt(in value: Any, matchingAnyOf keys: [String]) -> Int? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let direct = object[key] {
                    if let int = direct as? Int {
                        return int
                    }
                    if let number = direct as? NSNumber {
                        return number.intValue
                    }
                    if let string = direct as? String, let int = Int(string) {
                        return int
                    }
                }
            }

            for child in object.values {
                if let int = findInt(in: child, matchingAnyOf: keys) {
                    return int
                }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let int = findInt(in: item, matchingAnyOf: keys) {
                    return int
                }
            }
        }

        return nil
    }
}
