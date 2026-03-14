import Foundation

public enum EulerEventDecoder {
    public static func decodeRecord(from rawPayload: String, receivedAt: Date = Date()) -> EulerDebugEventRecord {
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
        let outcome = decodeOutcome(for: typedEvent)

        return EulerDebugEventRecord(
            eventName: eventName,
            rawPayload: rawPayload,
            decodedTypedEvent: typedEvent,
            decodeOutcome: outcome,
            receivedAt: receivedAt
        )
    }

    public static func documentedEventCoverage(from records: [EulerDebugEventRecord]) -> [EulerDocumentedEventCoverage] {
        EulerDocumentedEventKind.allCases.map { event in
            let matches = records.filter { record in
                recordMatchesDocumentedEvent(record, documentedEvent: event)
            }
            let payloadTypes = Array(Set(matches.compactMap { extractPrimaryMessageType(fromRawPayload: $0.rawPayload) })).sorted()

            return EulerDocumentedEventCoverage(
                event: event,
                implemented: matches.contains { $0.decodedTypedEvent?.eventName == event.rawValue },
                observedRecordCount: matches.count,
                observedPayloadTypes: payloadTypes
            )
        }
    }

    private static func decodeOutcome(for typedEvent: EulerLiveEvent?) -> EulerDecodeOutcome {
        guard let typedEvent else {
            return .unknownEvent
        }

        switch typedEvent {
        case .unknown:
            return .unknownEvent
        case .roomInfo(let event):
            let fields = [event.uniqueId, event.roomId, event.nickname, event.profilePictureURL].compactMap { $0 }
            return fields.count >= 2 ? .decoded : .decodedWithPartialData
        case .member(let event):
            let fields = [event.uniqueId, event.nickname, event.userId].compactMap { $0 }
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
            let hasStrongData = event.uniqueId != nil || event.nickname != nil || event.followerCount != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .share(let event):
            let hasStrongData = event.uniqueId != nil || event.nickname != nil || event.shareCount != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .roomUser(let event):
            let hasStrongData = event.viewerCount != nil || event.topGifterUniqueId != nil || event.topGifterNickname != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .liveIntro(let event):
            let hasStrongData = event.description != nil || event.hostNickname != nil || event.hostSecUid != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .roomMessage(let event):
            let hasStrongData = event.displayText != nil || event.content != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .workerInfo(let event):
            let hasStrongData = event.webSocketId != nil || event.schemaVersion != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .transportConnect(let event):
            let hasStrongData = event.agentId != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        }
    }

    private static func normalizedEventName(from object: [String: Any]) -> String {
        if let primaryType = extractPrimaryMessageType(from: object) {
            if primaryType.caseInsensitiveCompare("WebcastSocialMessage") == .orderedSame {
                return socialEventName(from: object)
            }
            return canonicalEventName(primaryType)
        }

        if let candidate = findString(in: object, matchingAnyOf: ["eventName", "event_name", "event", "type", "name", "messageType", "msgType"]) {
            return canonicalEventName(candidate)
        }

        if findString(in: object, matchingAnyOf: ["roomId", "room_id"]) != nil {
            return "room_info"
        }

        return "unknown"
    }

    private static func socialEventName(from object: [String: Any]) -> String {
        if let action = findString(in: object, matchingAnyOf: ["action"]) {
            switch action {
            case "1":
                return "follow"
            case "3":
                return "share"
            default:
                break
            }
        }

        if let pattern = findString(in: object, matchingAnyOf: ["defaultPattern"])?.lowercased() {
            if pattern.contains("followed the live") {
                return "follow"
            }
            if pattern.contains("shared the live") {
                return "share"
            }
        }

        return "webcastsocialmessage"
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
        case "member", "member_join", "join", "connected_user", "enter", "enter_room", "webcastmembermessage":
            return "member"
        case "gift", "gift_event", "webcastgiftmessage":
            return "gift"
        case "like", "like_event", "webcastlikemessage":
            return "like"
        case "comment", "chat", "chat_message", "comment_event", "webcastchatmessage":
            return "chat"
        case "follow", "follow_event":
            return "follow"
        case "share", "share_event":
            return "share"
        case "roomuser", "room_user", "webcastroomuserseqmessage":
            return "room_user"
        case "liveintro", "live_intro", "webcastliveintromessage":
            return "live_intro"
        case "roommessage", "room_message", "webcastroommessage":
            return "room_message"
        case "workerinfo", "worker_info":
            return "worker_info"
        case "tiktok.connect":
            return "tiktok.connect"
        default:
            return normalized
        }
    }

    private static func typedEvent(for eventName: String, payload: [String: Any]) -> EulerLiveEvent? {
        switch eventName {
        case "room_info":
            return .roomInfo(
                RoomInfoEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id", "ownerUniqueId"]),
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id", "id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    profilePictureURL: findString(in: payload, matchingAnyOf: ["profilePictureUrl", "profilePictureURL", "avatarThumb", "avatarUrl"]),
                    title: findString(in: payload, matchingAnyOf: ["title"]),
                    isLive: findBool(in: payload, matchingAnyOf: ["isLive"]),
                    currentViewers: findInt(in: payload, matchingAnyOf: ["currentViewers", "viewerCount"]),
                    totalViewers: findInt(in: payload, matchingAnyOf: ["totalViewers"])
                )
            )
        case "member":
            return .member(
                MemberEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    userId: findString(in: payload, matchingAnyOf: ["userId", "numericUid"]),
                    viewerCount: findInt(in: payload, matchingAnyOf: ["viewerCount", "memberCount"])
                )
            )
        case "gift":
            return .gift(
                GiftEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    giftName: findString(in: payload, matchingAnyOf: ["giftName", "gift_name", "name"]),
                    giftId: findInt(in: payload, matchingAnyOf: ["giftId", "gift_id", "id"]),
                    repeatCount: findInt(in: payload, matchingAnyOf: ["repeatCount", "repeat_count", "count"]),
                    repeatEnd: findBool(in: payload, matchingAnyOf: ["repeatEnd"])
                )
            )
        case "like":
            return .like(
                LikeEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    likeCount: findInt(in: payload, matchingAnyOf: ["likeCount", "like_count", "count"]),
                    totalLikeCount: findInt(in: payload, matchingAnyOf: ["totalLikeCount", "totalLikes", "total_like_count", "totalCount"])
                )
            )
        case "chat":
            return .comment(
                CommentEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    userId: findString(in: payload, matchingAnyOf: ["userId", "numericUid"]),
                    comment: findString(in: payload, matchingAnyOf: ["comment", "text", "message"]),
                    isModerator: findBool(in: payload, matchingAnyOf: ["isModeratorOfAnchor", "isAdmin"]),
                    isFollowerOfAnchor: findBool(in: payload, matchingAnyOf: ["isFollowerOfAnchor"])
                )
            )
        case "follow":
            return .follow(
                FollowEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    followerCount: findInt(in: payload, matchingAnyOf: ["followCount"])
                )
            )
        case "share":
            return .share(
                ShareEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    shareCount: findInt(in: payload, matchingAnyOf: ["shareCount"])
                )
            )
        case "room_user":
            return .roomUser(
                RoomUserEvent(
                    viewerCount: findInt(in: payload, matchingAnyOf: ["viewerCount"]),
                    topGifterUniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    topGifterNickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName"]),
                    topGifterCoinCount: findInt(in: payload, matchingAnyOf: ["coinCount"])
                )
            )
        case "live_intro":
            return .liveIntro(
                LiveIntroEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    description: findString(in: payload, matchingAnyOf: ["description"]),
                    hostUniqueId: findString(in: payload, matchingAnyOf: ["uniqueId"]),
                    hostNickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName"]),
                    hostSecUid: findString(in: payload, matchingAnyOf: ["secUid"])
                )
            )
        case "room_message":
            return .roomMessage(
                RoomMessageEvent(
                    content: findString(in: payload, matchingAnyOf: ["content"]),
                    source: findString(in: payload, matchingAnyOf: ["source"]),
                    scene: findInt(in: payload, matchingAnyOf: ["scene"]),
                    displayText: findString(in: payload, matchingAnyOf: ["defaultPattern"])
                )
            )
        case "worker_info":
            return .workerInfo(
                WorkerInfoEvent(
                    webSocketId: findString(in: payload, matchingAnyOf: ["webSocketId"]),
                    schemaVersion: findString(in: payload, matchingAnyOf: ["schemaVersion"]),
                    isLoggedIn: findBool(in: payload, matchingAnyOf: ["isLoggedIn"]),
                    bundleEvents: findBool(in: payload, matchingAnyOf: ["bundleEvents"]),
                    rawMessages: findBool(in: payload, matchingAnyOf: ["rawMessages"])
                )
            )
        case "tiktok.connect":
            return .transportConnect(
                TransportConnectEvent(
                    agentId: findString(in: payload, matchingAnyOf: ["agentId"])
                )
            )
        case "unknown":
            return nil
        default:
            return .unknown(eventName: eventName)
        }
    }

    private static func extractPrimaryMessageType(from object: [String: Any]) -> String? {
        if let messages = object["messages"] as? [[String: Any]], let first = messages.first, let type = first["type"] as? String {
            return type
        }
        return nil
    }

    private static func recordMatchesDocumentedEvent(_ record: EulerDebugEventRecord, documentedEvent: EulerDocumentedEventKind) -> Bool {
        if record.decodedTypedEvent?.eventName == documentedEvent.rawValue {
            return true
        }

        let primaryType = extractPrimaryMessageType(fromRawPayload: record.rawPayload)?.lowercased() ?? ""
        switch documentedEvent {
        case .roomInfo:
            return record.eventName == "room_info" || primaryType == "roominfo"
        case .member:
            return record.eventName == "member" || primaryType == "webcastmembermessage"
        case .gift:
            return record.eventName == "gift" || primaryType == "webcastgiftmessage"
        case .like:
            return record.eventName == "like" || primaryType == "webcastlikemessage"
        case .chat:
            return record.eventName == "chat" || primaryType == "webcastchatmessage"
        case .follow:
            return record.eventName == "follow" || primaryType == "webcastsocialmessage"
        case .share:
            return record.eventName == "share" || primaryType == "webcastsocialmessage"
        case .roomUser:
            return record.eventName == "room_user" || primaryType == "webcastroomuserseqmessage"
        case .liveIntro:
            return record.eventName == "live_intro" || primaryType == "webcastliveintromessage"
        case .roomMessage:
            return record.eventName == "room_message" || primaryType == "webcastroommessage"
        }
    }

    private static func extractPrimaryMessageType(fromRawPayload rawPayload: String) -> String? {
        guard
            let data = rawPayload.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        return extractPrimaryMessageType(from: json)
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

    private static func findBool(in value: Any, matchingAnyOf keys: [String]) -> Bool? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let direct = object[key] {
                    if let bool = direct as? Bool {
                        return bool
                    }
                    if let number = direct as? NSNumber {
                        return number.boolValue
                    }
                    if let string = direct as? String {
                        switch string.lowercased() {
                        case "true", "1":
                            return true
                        case "false", "0":
                            return false
                        default:
                            break
                        }
                    }
                }
            }

            for child in object.values {
                if let bool = findBool(in: child, matchingAnyOf: keys) {
                    return bool
                }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let bool = findBool(in: item, matchingAnyOf: keys) {
                    return bool
                }
            }
        }

        return nil
    }
}
