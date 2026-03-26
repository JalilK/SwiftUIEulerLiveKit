import Foundation

public enum EulerEventDecoder {
    public static func decodeRecord(from rawPayload: String, receivedAt: Date = Date()) -> EulerDebugEventRecord {
        guard let data = rawPayload.data(using: .utf8) else {
            return EulerDebugEventRecord(eventName: "invalid_payload", rawPayload: rawPayload, decodedTypedEvent: nil, decodeOutcome: .invalidJSON, receivedAt: receivedAt)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return EulerDebugEventRecord(eventName: "invalid_payload", rawPayload: rawPayload, decodedTypedEvent: nil, decodeOutcome: .invalidJSON, receivedAt: receivedAt)
        }

        guard let object = json as? [String: Any] else {
            return EulerDebugEventRecord(eventName: "unsupported_payload", rawPayload: rawPayload, decodedTypedEvent: nil, decodeOutcome: .unsupportedPayload, receivedAt: receivedAt)
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

    public static func decodeRecords(from rawPayload: String, receivedAt: Date = Date()) -> [EulerDebugEventRecord] {
        guard let payloadData = rawPayload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let messages = json["messages"] as? [[String: Any]],
              messages.count > 1 else {
            return [decodeRecord(from: rawPayload, receivedAt: receivedAt)]
        }

        return messages.compactMap { message in
            var singleEnvelope: [String: Any] = json
            singleEnvelope["messages"] = [message]

            guard let data = try? JSONSerialization.data(withJSONObject: singleEnvelope),
                  let text = String(data: data, encoding: .utf8) else {
                return nil
            }

            return decodeRecord(from: text, receivedAt: receivedAt)
        }
    }

    public static func documentedEventCoverage(from records: [EulerDebugEventRecord]) -> [EulerDocumentedEventCoverage] {
        EulerDocumentedEventKind.allCases.map { event in
            let matches = records.filter { record in
                recordMatchesDocumentedEvent(record, documentedEvent: event)
            }
            let payloadTypes = Array(Set(matches.compactMap { extractPrimaryMessageType(fromRawPayload: $0.rawPayload) })).sorted()

            return EulerDocumentedEventCoverage(
                event: event,
                implemented: event.implemented,
                observedRecordCount: matches.count,
                observedPayloadTypes: payloadTypes
            )
        }
    }

    private static func decodeOutcome(for typedEvent: EulerLiveEvent?) -> EulerDecodeOutcome {
        guard let typedEvent else { return .unknownEvent }

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
            let hasStrongData = event.giftName != nil || event.giftId != nil || event.uniqueId != nil || event.nickname != nil || event.profilePictureURL != nil || event.profilePictureURL != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .like(let event):
            let hasStrongData = event.likeCount != nil || event.totalLikeCount != nil || event.uniqueId != nil || event.nickname != nil || event.profilePictureURL != nil || event.profilePictureURL != nil
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
        case .caption(let event):
            return event.lines.isEmpty ? .decodedWithPartialData : .decoded
        case .barrage(let event):
            let hasStrongData = event.displayText != nil || event.uniqueId != nil || event.nickname != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkMicFanTicket(let event):
            let hasStrongData = event.totalLinkMicFanTicket != nil || !event.users.isEmpty
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkMicArmies(let event):
            let hasStrongData = event.battleId != nil || !event.sides.isEmpty
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .goalUpdate(let event):
            let hasStrongData = event.goalId != nil || event.goalDescription != nil || !event.subGoals.isEmpty || !event.contributors.isEmpty
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkMicMethod(let event):
            let hasStrongData = event.messageType != nil || event.totalLinkMicFanTicket != nil || event.userId != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .inRoomBanner(let event):
            let hasStrongData = !event.currents.isEmpty || !event.playerStates.isEmpty
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkLayer(let event):
            let hasStrongData = event.scene != nil || event.messageType != nil || !event.participants.isEmpty
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .socialRepost(let event):
            let hasStrongData = event.uniqueId != nil || event.nickname != nil || event.displayText != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkMicBattle(let event):
            let hasStrongData = event.battleId != nil || event.status != nil || event.leftUserId != nil || event.rightUserId != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkMicBattleTask(let event):
            let hasStrongData = event.battleId != nil || event.messageType != nil || event.taskProgress != nil || event.taskResult != nil || event.rewardSettleAmount != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .unauthorizedMember(let event):
            let hasStrongData = event.nickname != nil || event.enterText != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .moderationDelete(let event):
            let hasStrongData = !event.deletedUserIds.isEmpty || !event.deletedMessageIds.isEmpty
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkMicBattlePunishFinish(let event):
            let hasStrongData = event.battleId != nil || event.operatorUserId != nil || event.reason != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .linkMessage(let event):
            let hasStrongData = event.scene != nil || event.linkerId != nil || event.messageType != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .workerInfo(let event):
            let hasStrongData = event.webSocketId != nil || event.schemaVersion != nil
            return hasStrongData ? .decoded : .decodedWithPartialData
        case .transportConnect(let event):
            return event.agentId != nil ? .decoded : .decodedWithPartialData
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
            case "1": return "follow"
            case "3": return "share"
            case "4":
                if let pattern = findString(in: object, matchingAnyOf: ["defaultPattern"])?.lowercased(), pattern.contains("reposted") {
                    return "social_repost"
                }
            default: break
            }
        }

        if let pattern = findString(in: object, matchingAnyOf: ["defaultPattern"])?.lowercased() {
            if pattern.contains("followed the live") { return "follow" }
            if pattern.contains("shared the live") { return "share" }
            if pattern.contains("reposted") { return "social_repost" }
        }

        return "webcastsocialmessage"
    }

    private static func findProfilePictureURL(in payload: [String: Any]) -> String? {
        if let direct = findString(in: payload, matchingAnyOf: ["profilePictureUrl", "profilePictureURL", "avatarUrl", "avatarThumb"]) {
            return direct
        }

        if let user = nestedDictionary(in: payload, matchingAnyOf: ["user"]),
           let direct = findString(in: user, matchingAnyOf: ["profilePictureUrl", "profilePictureURL", "avatarUrl", "avatarThumb"]) {
            return direct
        }

        if let avatarThumb = nestedDictionary(in: payload, matchingAnyOf: ["avatarThumb"]),
           let thumbURL = firstStringURL(in: avatarThumb) {
            return thumbURL
        }

        if let user = nestedDictionary(in: payload, matchingAnyOf: ["user"]),
           let avatarThumb = nestedDictionary(in: user, matchingAnyOf: ["avatarThumb"]),
           let thumbURL = firstStringURL(in: avatarThumb) {
            return thumbURL
        }

        return nil
    }

    private static func nestedDictionary(in object: [String: Any], matchingAnyOf keys: [String]) -> [String: Any]? {
        for key in keys {
            if let value = object[key] as? [String: Any] {
                return value
            }
        }

        for value in object.values {
            if let nested = value as? [String: Any],
               let found = nestedDictionary(in: nested, matchingAnyOf: keys) {
                return found
            }

            if let array = value as? [Any] {
                for item in array {
                    if let nested = item as? [String: Any],
                       let found = nestedDictionary(in: nested, matchingAnyOf: keys) {
                        return found
                    }
                }
            }
        }

        return nil
    }

    private static func firstStringURL(in object: [String: Any]) -> String? {
        if let url = object["url"] as? String, url.isEmpty == false {
            return url
        }

        if let urls = object["urlList"] as? [String], let first = urls.first, first.isEmpty == false {
            return first
        }

        if let urls = object["url_list"] as? [String], let first = urls.first, first.isEmpty == false {
            return first
        }

        for value in object.values {
            if let nested = value as? [String: Any], let found = firstStringURL(in: nested) {
                return found
            }

            if let urls = value as? [String], let first = urls.first, first.isEmpty == false {
                return first
            }
        }

        return nil
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
        case "captionmessage", "caption_message", "webcastcaptionmessage":
            return "caption_message"
        case "barrage", "webcastbarragemessage":
            return "barrage"
        case "linkmicfanticketmethod", "link_mic_fan_ticket_method", "webcastlinkmicfanticketmethod":
            return "link_mic_fan_ticket_method"
        case "linkmicarmies", "link_mic_armies", "webcastlinkmicarmies":
            return "link_mic_armies"
        case "goalupdatemessage", "goal_update", "webcastgoalupdatemessage":
            return "goal_update"
        case "linkmicmethod", "link_mic_method", "webcastlinkmicmethod":
            return "link_mic_method"
        case "inroombannermessage", "in_room_banner", "webcastinroombannermessage":
            return "in_room_banner"
        case "linklayermessage", "link_layer", "webcastlinklayermessage":
            return "link_layer"
        case "social_repost":
            return "social_repost"
        case "linkmicbattle", "link_mic_battle", "webcastlinkmicbattle":
            return "link_mic_battle"
        case "linkmicbattletaskmessage", "link_mic_battle_task", "webcastlinkmicbattletaskmessage":
            return "link_mic_battle_task"
        case "unauthorizedmembermessage", "unauthorized_member", "webcastunauthorizedmembermessage":
            return "unauthorized_member"
        case "imdeletemessage", "moderation_delete", "webcastimdeletemessage":
            return "moderation_delete"
        case "linkmicbattlepunishfinish", "link_mic_battle_punish_finish", "webcastlinkmicbattlepunishfinish":
            return "link_mic_battle_punish_finish"
        case "linkmessage", "link_message", "webcastlinkmessage":
            return "link_message"
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
                    profilePictureURL: findProfilePictureURL(in: payload),
                    giftName: findString(in: payload, matchingAnyOf: ["giftName", "name", "gift_name"]),
                    giftId: findInt(in: payload, matchingAnyOf: ["giftId", "gift_id", "id"]),
                    repeatCount: findInt(in: payload, matchingAnyOf: ["repeatCount", "repeat_count", "comboCount", "count"]),
                    repeatEnd: findBool(in: payload, matchingAnyOf: ["repeatEnd"]),
                    giftType: findInt(in: payload, matchingAnyOf: ["giftType"]),
                    displayText: findString(in: payload, matchingAnyOf: ["describe", "defaultPattern"]),
                    groupId: findString(in: payload, matchingAnyOf: ["groupId"]),
                    comboCount: findInt(in: payload, matchingAnyOf: ["comboCount"]),
                    diamondCount: findInt(in: payload, matchingAnyOf: ["diamondCount"])
                )
            )
        case "like":
            return .like(
                LikeEvent(
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "unique_id"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName", "displayName"]),
                    profilePictureURL: findProfilePictureURL(in: payload),
                    likeCount: findInt(in: payload, matchingAnyOf: ["likeCount", "count"]),
                    totalLikeCount: findInt(in: payload, matchingAnyOf: ["totalLikeCount", "totalLikes"]),
                    displayText: findString(in: payload, matchingAnyOf: ["defaultPattern"])
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
        case "caption_message":
            return .caption(
                CaptionEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    timestampMs: findInt(in: payload, matchingAnyOf: ["timestampMs"]),
                    durationMs: findInt(in: payload, matchingAnyOf: ["durationMs"]),
                    sentenceId: findString(in: payload, matchingAnyOf: ["sentenceId"]),
                    sequenceId: findString(in: payload, matchingAnyOf: ["sequenceId"]),
                    definite: findBool(in: payload, matchingAnyOf: ["definite"]),
                    lines: extractCaptionLines(from: payload)
                )
            )
        case "barrage":
            return .barrage(
                BarrageEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    messageType: findInt(in: payload, matchingAnyOf: ["msgType"]),
                    durationMs: findInt(in: payload, matchingAnyOf: ["duration"]),
                    displayText: findString(in: payload, matchingAnyOf: ["defaultPattern"]),
                    userId: findString(in: payload, matchingAnyOf: ["userId", "fromUserId"]),
                    uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId", "displayId"]),
                    nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName"])
                )
            )
        case "link_mic_fan_ticket_method":
            return .linkMicFanTicket(
                LinkMicFanTicketEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    totalLinkMicFanTicket: findInt(in: payload, matchingAnyOf: ["TotalLinkMicFanTicket"]),
                    matchId: findString(in: payload, matchingAnyOf: ["MatchId"]),
                    eventTime: findInt(in: payload, matchingAnyOf: ["EventTime"]),
                    playId: findString(in: payload, matchingAnyOf: ["playId"]),
                    playScene: findInt(in: payload, matchingAnyOf: ["playScene"]),
                    users: extractLinkMicFanTicketUsers(from: payload)
                )
            )
        case "link_mic_armies":
            return .linkMicArmies(
                LinkMicArmiesEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    battleId: findString(in: payload, matchingAnyOf: ["battleId"]),
                    channelId: findString(in: payload, matchingAnyOf: ["channelId"]),
                    battleStatus: findInt(in: payload, matchingAnyOf: ["battleStatus"]),
                    giftId: findInt(in: payload, matchingAnyOf: ["giftId"]),
                    giftCount: findInt(in: payload, matchingAnyOf: ["giftCount"]),
                    repeatCount: findInt(in: payload, matchingAnyOf: ["repeatCount"]),
                    totalDiamondCount: findInt(in: payload, matchingAnyOf: ["totalDiamondCount"]),
                    fromUserId: findString(in: payload, matchingAnyOf: ["fromUserId"]),
                    scoreUpdateTime: findInt(in: payload, matchingAnyOf: ["scoreUpdateTime"]),
                    giftSentTime: findInt(in: payload, matchingAnyOf: ["giftSentTime"]),
                    sides: extractLinkMicArmySides(from: payload)
                )
            )
        case "goal_update":
            return .goalUpdate(
                GoalUpdateEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    goalId: findString(in: payload, matchingAnyOf: ["id", "idStr"]),
                    goalDescription: findString(in: payload, matchingAnyOf: ["description", "auditDescription"]),
                    goalType: findInt(in: payload, matchingAnyOf: ["type"]),
                    goalStatus: findInt(in: payload, matchingAnyOf: ["status"]),
                    indicatorKey: findString(in: payload, matchingAnyOf: ["key"]),
                    indicatorOperation: findInt(in: payload, matchingAnyOf: ["op"]),
                    updateSource: findInt(in: payload, matchingAnyOf: ["updateSource"]),
                    contributorId: findString(in: payload, matchingAnyOf: ["contributorId"]),
                    contributorIdStr: findString(in: payload, matchingAnyOf: ["contributorIdStr"]),
                    contributorDisplayId: findString(in: payload, matchingAnyOf: ["contributorDisplayId"]),
                    contributeScore: findInt(in: payload, matchingAnyOf: ["contributeScore"]),
                    contributeCount: findInt(in: payload, matchingAnyOf: ["contributeCount"]),
                    pin: findBool(in: payload, matchingAnyOf: ["pin"]),
                    unpin: findBool(in: payload, matchingAnyOf: ["unpin"]),
                    subGoals: extractGoalSubGoals(from: payload),
                    contributors: extractGoalContributors(from: payload)
                )
            )
        case "link_mic_method":
            return .linkMicMethod(
                LinkMicMethodEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    messageType: findInt(in: payload, matchingAnyOf: ["messageType"]),
                    userId: findString(in: payload, matchingAnyOf: ["userId"]),
                    fanTicket: findInt(in: payload, matchingAnyOf: ["fanTicket"]),
                    totalLinkMicFanTicket: findInt(in: payload, matchingAnyOf: ["totalLinkMicFanTicket"]),
                    channelId: findString(in: payload, matchingAnyOf: ["channelId"]),
                    anchorLinkMicId: findString(in: payload, matchingAnyOf: ["anchorLinkmicId", "anchorLinkMicId"]),
                    rivalAnchorId: findString(in: payload, matchingAnyOf: ["rivalAnchorId"]),
                    matchType: findInt(in: payload, matchingAnyOf: ["matchType"]),
                    win: findBool(in: payload, matchingAnyOf: ["win"]),
                    shouldShowPopup: findBool(in: payload, matchingAnyOf: ["shouldShowPopup"]),
                    rtcJoinChannel: findBool(in: payload, matchingAnyOf: ["rtcJoinChannel"])
                )
            )
        case "in_room_banner":
            let parsedBanner = parseEmbeddedJSONStringDictionary(from: payload, keys: ["data"])
            return .inRoomBanner(
                InRoomBannerEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    position: findInt(in: payload, matchingAnyOf: ["position"]),
                    actionType: findInt(in: payload, matchingAnyOf: ["actionType"]),
                    currents: extractInRoomBannerCurrents(from: parsedBanner),
                    playerStates: extractInRoomBannerPlayerStates(from: parsedBanner)
                )
            )
        case "link_layer":
            return .linkLayer(
                LinkLayerEvent(
                    roomId: findString(in: payload, matchingAnyOf: ["roomId", "room_id"]),
                    scene: findInt(in: payload, matchingAnyOf: ["scene"]),
                    messageType: findInt(in: payload, matchingAnyOf: ["messageType"]),
                    channelId: findString(in: payload, matchingAnyOf: ["channelId"]),
                    source: findString(in: payload, matchingAnyOf: ["source"]),
                    rtcRoomId: findString(in: payload, matchingAnyOf: ["rtcRoomId"]),
                    participants: extractLinkLayerParticipants(from: payload)
                )
            )
        case "social_repost":
            return .socialRepost(extractSocialRepostEvent(from: payload))
        case "link_mic_battle":
            return .linkMicBattle(extractLinkMicBattleEvent(from: payload))
        case "link_mic_battle_task":
            return .linkMicBattleTask(extractLinkMicBattleTaskEvent(from: payload))
        case "unauthorized_member":
            return .unauthorizedMember(extractUnauthorizedMemberEvent(from: payload))
        case "moderation_delete":
            return .moderationDelete(extractModerationDeleteEvent(from: payload))
        case "link_mic_battle_punish_finish":
            return .linkMicBattlePunishFinish(extractLinkMicBattlePunishFinishEvent(from: payload))
        case "link_message":
            return .linkMessage(extractLinkMessageEvent(from: payload))
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
            return .transportConnect(TransportConnectEvent(agentId: findString(in: payload, matchingAnyOf: ["agentId"])))
        case "unknown":
            return nil
        default:
            return .unknown(eventName: eventName)
        }
    }

    private static func recordMatchesDocumentedEvent(_ record: EulerDebugEventRecord, documentedEvent: EulerDocumentedEventKind) -> Bool {
        if record.decodedTypedEvent?.eventName == documentedEvent.rawValue {
            return true
        }

        let primaryType = extractPrimaryMessageType(fromRawPayload: record.rawPayload)?.lowercased() ?? ""
        switch documentedEvent {
        case .roomInfo: return record.eventName == "room_info" || primaryType == "roominfo"
        case .member: return record.eventName == "member" || primaryType == "webcastmembermessage"
        case .gift: return record.eventName == "gift" || primaryType == "webcastgiftmessage"
        case .like: return record.eventName == "like" || primaryType == "webcastlikemessage"
        case .chat: return record.eventName == "chat" || primaryType == "webcastchatmessage"
        case .follow: return record.eventName == "follow" || primaryType == "webcastsocialmessage"
        case .share: return record.eventName == "share" || primaryType == "webcastsocialmessage"
        case .roomUser: return record.eventName == "room_user" || primaryType == "webcastroomuserseqmessage"
        case .liveIntro: return record.eventName == "live_intro" || primaryType == "webcastliveintromessage"
        case .roomMessage: return record.eventName == "room_message" || primaryType == "webcastroommessage"
        case .captionMessage: return record.eventName == "caption_message" || primaryType == "webcastcaptionmessage"
        case .barrage: return record.eventName == "barrage" || primaryType == "webcastbarragemessage"
        case .linkMicFanTicketMethod: return record.eventName == "link_mic_fan_ticket_method" || primaryType == "webcastlinkmicfanticketmethod"
        case .linkMicArmies: return record.eventName == "link_mic_armies" || primaryType == "webcastlinkmicarmies"
        case .goalUpdate: return record.eventName == "goal_update" || primaryType == "webcastgoalupdatemessage"
        case .linkMicMethod: return record.eventName == "link_mic_method" || primaryType == "webcastlinkmicmethod"
        case .inRoomBanner: return record.eventName == "in_room_banner" || primaryType == "webcastinroombannermessage"
        case .linkLayer: return record.eventName == "link_layer" || primaryType == "webcastlinklayermessage"
        }
    }

    private static func extractPrimaryMessageType(from object: [String: Any]) -> String? {
        if let messages = object["messages"] as? [[String: Any]],
           let first = messages.first,
           let type = first["type"] as? String {
            return type
        }
        return nil
    }

    private static func extractPrimaryMessageType(fromRawPayload rawPayload: String) -> String? {
        guard let data = rawPayload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return extractPrimaryMessageType(from: json)
    }

    private static func extractCaptionLines(from payload: [String: Any]) -> [CaptionLine] {
        guard let content = findArray(in: payload, matchingAnyOf: ["content"]) else { return [] }
        return content.compactMap { item in
            guard let object = item as? [String: Any] else { return nil }
            return CaptionLine(language: object["lang"] as? String, content: object["content"] as? String)
        }
    }

    private static func extractLinkMicFanTicketUsers(from payload: [String: Any]) -> [LinkMicFanTicketUser] {
        guard let users = findArray(in: payload, matchingAnyOf: ["UserFanTicketList"]) else { return [] }
        return users.compactMap { item in
            guard let object = item as? [String: Any] else { return nil }
            return LinkMicFanTicketUser(
                userId: object["UserId"] as? String,
                fanTicket: int(fromAny: object["FanTicket"]),
                matchTotalScore: int(fromAny: object["MatchTotalScore"]),
                matchRank: int(fromAny: object["MatchRank"])
            )
        }
    }


    private static func extractSocialRepostEvent(from payload: [String: Any]) -> SocialRepostEvent {
        SocialRepostEvent(
            roomId: findString(in: payload, matchingAnyOf: ["roomId"]),
            userId: findString(in: payload, matchingAnyOf: ["userId"]),
            uniqueId: findString(in: payload, matchingAnyOf: ["uniqueId"]),
            nickname: findString(in: payload, matchingAnyOf: ["nickname", "nickName"]),
            action: findInt(in: payload, matchingAnyOf: ["action"]),
            shareType: findInt(in: payload, matchingAnyOf: ["shareType"]),
            shareCount: findInt(in: payload, matchingAnyOf: ["shareCount"]),
            displayText: findString(in: payload, matchingAnyOf: ["defaultPattern"])
        )
    }

    private static func extractUnauthorizedMemberEvent(from payload: [String: Any]) -> UnauthorizedMemberEvent {
        UnauthorizedMemberEvent(
            roomId: findString(in: payload, matchingAnyOf: ["roomId"]),
            nickname: findString(in: payload, matchingAnyOf: ["nickName", "nickname"]),
            action: findInt(in: payload, matchingAnyOf: ["action"]),
            enterText: findString(in: payload, matchingAnyOf: ["defaultPattern"])
        )
    }

    private static func extractModerationDeleteEvent(from payload: [String: Any]) -> ModerationDeleteEvent {
        ModerationDeleteEvent(
            roomId: findString(in: payload, matchingAnyOf: ["roomId"]),
            deletedUserIds: extractStringArray(in: payload, matchingAnyOf: ["deleteUserIdsList"]),
            deletedMessageIds: extractStringArray(in: payload, matchingAnyOf: ["deleteMsgIdsList"])
        )
    }

    private static func extractLinkMicBattlePunishFinishEvent(from payload: [String: Any]) -> LinkMicBattlePunishFinishEvent {
        let battleSettings = findDictionary(in: payload, matchingAnyOf: ["battleSettings"]) ?? [:]

        return LinkMicBattlePunishFinishEvent(
            roomId: findString(in: payload, matchingAnyOf: ["roomId"]),
            battleId: findString(in: payload, matchingAnyOf: ["battleId"]),
            channelId: findString(in: payload, matchingAnyOf: ["channelId"]),
            operatorUserId: findString(in: payload, matchingAnyOf: ["opUid"]),
            reason: findInt(in: payload, matchingAnyOf: ["reason"]),
            status: int(fromAny: battleSettings["status"]),
            endTimeMs: string(fromAny: battleSettings["endTimeMs"])
        )
    }

    private static func extractLinkMessageEvent(from payload: [String: Any]) -> LinkMessageEvent {
        let extraValue = findString(in: payload, matchingAnyOf: ["extra"])
        let transferExtraValue = findString(in: payload, matchingAnyOf: ["transferExtra"])

        return LinkMessageEvent(
            roomId: findString(in: payload, matchingAnyOf: ["roomId"]),
            scene: findInt(in: payload, matchingAnyOf: ["Scene", "scene"]),
            linkerId: findString(in: payload, matchingAnyOf: ["LinkerId", "linkerId"]),
            messageType: findInt(in: payload, matchingAnyOf: ["MessageType", "messageType"]),
            expireTimestamp: findString(in: payload, matchingAnyOf: ["expireTimestamp"]),
            extra: (extraValue == "") ? nil : extraValue,
            transferExtra: (transferExtraValue == "") ? nil : transferExtraValue
        )
    }

    private static func extractLinkMicBattleEvent(from payload: [String: Any]) -> LinkMicBattleEvent {
        let anchorInfo = findDictionary(in: payload, matchingAnyOf: ["anchorInfo"]) ?? [:]
        let battleResult = findDictionary(in: payload, matchingAnyOf: ["battleResult"]) ?? [:]
        let battleCombos = findDictionary(in: payload, matchingAnyOf: ["battleCombos"]) ?? [:]
        let anchorIds = Array(anchorInfo.keys).sorted()

        func anchorField(_ anchorId: String?, _ key: String) -> Any? {
            guard let anchorId,
                  let anchorObject = anchorInfo[anchorId] as? [String: Any],
                  let user = anchorObject["user"] as? [String: Any] else { return nil }
            return user[key]
        }

        func resultField(_ anchorId: String?, _ key: String) -> Any? {
            guard let anchorId,
                  let resultObject = battleResult[anchorId] as? [String: Any] else { return nil }
            return resultObject[key]
        }

        func comboField(_ anchorId: String?, _ key: String) -> Any? {
            guard let anchorId,
                  let comboObject = battleCombos[anchorId] as? [String: Any] else { return nil }
            return comboObject[key]
        }

        let leftId = anchorIds.first
        let rightId = anchorIds.count > 1 ? anchorIds[1] : nil

        return LinkMicBattleEvent(
            roomId: findString(in: payload, matchingAnyOf: ["roomId"]),
            battleId: findString(in: payload, matchingAnyOf: ["battleId"]),
            channelId: findString(in: payload, matchingAnyOf: ["channelId"]),
            status: findInt(in: payload, matchingAnyOf: ["status"]),
            action: findInt(in: payload, matchingAnyOf: ["action"]),
            inviteType: findInt(in: payload, matchingAnyOf: ["inviteType"]),
            duration: findInt(in: payload, matchingAnyOf: ["duration"]),
            battleType: findInt(in: payload, matchingAnyOf: ["battleType"]),
            startTimeMs: findString(in: payload, matchingAnyOf: ["startTimeMs"]),
            endTimeMs: findString(in: payload, matchingAnyOf: ["endTimeMs"]),
            actionByUserId: findString(in: payload, matchingAnyOf: ["actionByUserId"]),
            leftUserId: leftId,
            leftDisplayId: string(fromAny: anchorField(leftId, "displayId")),
            leftNickname: string(fromAny: anchorField(leftId, "nickName")),
            rightUserId: rightId,
            rightDisplayId: string(fromAny: anchorField(rightId, "displayId")),
            rightNickname: string(fromAny: anchorField(rightId, "nickName")),
            leftScore: int(fromAny: resultField(leftId, "score")),
            rightScore: int(fromAny: resultField(rightId, "score")),
            leftResult: int(fromAny: resultField(leftId, "result")),
            rightResult: int(fromAny: resultField(rightId, "result")),
            leftComboCount: int(fromAny: comboField(leftId, "comboCount")),
            rightComboCount: int(fromAny: comboField(rightId, "comboCount"))
        )
    }

    private static func extractLinkMicBattleTaskEvent(from payload: [String: Any]) -> LinkMicBattleTaskEvent {
        return LinkMicBattleTaskEvent(
            roomId: findString(in: payload, matchingAnyOf: ["roomId"]),
            battleId: findString(in: payload, matchingAnyOf: ["battleId"]),
            messageType: findInt(in: payload, matchingAnyOf: ["battleTaskMessageType"]),
            taskProgress: findInt(in: payload, matchingAnyOf: ["taskProgress"]),
            fromUserUid: findString(in: payload, matchingAnyOf: ["fromUserUid"]),
            taskResult: findInt(in: payload, matchingAnyOf: ["taskResult"]),
            rewardStartTimestamp: findString(in: payload, matchingAnyOf: ["rewardStartTimestamp"]),
            rewardStartTime: findInt(in: payload, matchingAnyOf: ["rewardStartTime"]),
            rewardMultiple: findInt(in: payload, matchingAnyOf: ["rewardMultiple"]),
            rewardSettleAmount: extractRewardSettleAmount(from: payload),
            rewardStatus: findInt(in: payload, matchingAnyOf: ["status"]),
            progressTarget: findInt(in: payload, matchingAnyOf: ["progressTarget"])
        )
    }


    private static func extractRewardSettleAmount(from payload: [String: Any]) -> Int? {
        if let direct = findInt(in: payload, matchingAnyOf: ["sum"]) {
            return direct
        }

        guard
            let rewardSettle = findDictionary(in: payload, matchingAnyOf: ["rewardSettle"]),
            let rewardSettlePrompt = findDictionary(in: rewardSettle, matchingAnyOf: ["rewardSettlePrompt"]),
            let promptElements = findArray(in: rewardSettlePrompt, matchingAnyOf: ["promptElements"])
        else {
            return nil
        }

        for element in promptElements {
            guard let elementDict = element as? [String: Any] else { continue }
            let key = findString(in: elementDict, matchingAnyOf: ["promptFieldKey"])
            if key == "sum", let value = findInt(in: elementDict, matchingAnyOf: ["promptFieldValue"]) {
                return value
            }
        }

        return nil
    }

    private static func extractStringArray(in value: Any, matchingAnyOf keys: [String]) -> [String] {
        if let object = value as? [String: Any] {
            for key in keys {
                if let array = object[key] as? [Any] {
                    return array.compactMap { string(fromAny: $0) }
                }
            }
            for child in object.values {
                let nested = extractStringArray(in: child, matchingAnyOf: keys)
                if !nested.isEmpty {
                    return nested
                }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                let nested = extractStringArray(in: item, matchingAnyOf: keys)
                if !nested.isEmpty {
                    return nested
                }
            }
        }

        return []
    }

    private static func extractLinkMicArmySides(from payload: [String: Any]) -> [LinkMicArmySide] {
        guard let battleItems = findDictionary(in: payload, matchingAnyOf: ["battleItems"]) else { return [] }

        return battleItems.compactMap { key, value in
            guard let sideObject = value as? [String: Any] else { return nil }

            let hostScore = int(fromAny: sideObject["hostScore"]) ?? findInt(in: sideObject, matchingAnyOf: ["hostScore"])
            let anchorId = (sideObject["anchorIdStr"] as? String) ?? key

            let users: [LinkMicArmyUser]
            if let userArmy = sideObject["userArmy"] as? [[String: Any]] {
                users = userArmy.map { userObject in
                    LinkMicArmyUser(
                        userId: userObject["userId"] as? String,
                        userIdStr: userObject["userIdStr"] as? String,
                        nickname: userObject["nickname"] as? String,
                        score: int(fromAny: userObject["score"]),
                        diamondScore: int(fromAny: userObject["diamondScore"])
                    )
                }
            } else {
                users = []
            }

            return LinkMicArmySide(anchorId: anchorId, hostScore: hostScore, users: users)
        }
        .sorted { $0.anchorId < $1.anchorId }
    }

    private static func extractGoalContributors(from payload: [String: Any]) -> [GoalContributor] {
        guard let contributors = findArray(in: payload, matchingAnyOf: ["contributors"]) else { return [] }

        return contributors.compactMap { item in
            guard let object = item as? [String: Any] else { return nil }
            return GoalContributor(
                userId: string(fromAny: object["userId"]),
                userIdStr: object["userIdStr"] as? String,
                displayId: object["displayId"] as? String,
                score: int(fromAny: object["score"]),
                inRoom: bool(fromAny: object["inRoom"]),
                isFriend: bool(fromAny: object["isFriend"])
            )
        }
    }

    private static func extractGoalSubGoals(from payload: [String: Any]) -> [GoalSubGoal] {
        guard let subGoals = findArray(in: payload, matchingAnyOf: ["subGoals"]) else { return [] }

        return subGoals.compactMap { item in
            guard let object = item as? [String: Any] else { return nil }
            let gift = object["gift"] as? [String: Any]

            return GoalSubGoal(
                id: string(fromAny: object["id"]),
                idStr: object["idStr"] as? String,
                target: int(fromAny: object["target"]),
                progress: int(fromAny: object["progress"]),
                source: int(fromAny: object["source"]),
                type: int(fromAny: object["type"]),
                giftName: gift?["name"] as? String,
                giftDiamondCount: int(fromAny: gift?["diamondCount"])
            )
        }
    }

    private static func parseEmbeddedJSONStringDictionary(from payload: [String: Any], keys: [String]) -> [String: Any] {
        for key in keys {
            if let text = findString(in: payload, matchingAnyOf: [key]),
               let data = text.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return json
            }
        }
        return [:]
    }

    private static func extractInRoomBannerCurrents(from payload: [String: Any]) -> [InRoomBannerCurrent] {
        guard let activityIndicator = payload["activity_indicator"] as? [String: Any],
              let currents = activityIndicator["currents"] as? [[String: Any]] else {
            return []
        }

        return currents.map { current in
            InRoomBannerCurrent(
                activityCode: current["activity_code"] as? String,
                now: int(fromAny: current["now"]),
                phaseName: current["phase_name"] as? String
            )
        }
    }

    private static func extractInRoomBannerPlayerStates(from payload: [String: Any]) -> [InRoomBannerPlayerState] {
        guard let activityIndicator = payload["activity_indicator"] as? [String: Any],
              let states = activityIndicator["user_rank__player_state"] as? [[String: Any]] else {
            return []
        }

        return states.map { item in
            let base = item["base"] as? [String: Any]
            let state = item["state"] as? [String: Any]
            let comparison = state?["comparison"] as? [String: Any]
            let contributors = (state?["lead_contributors"] as? [[String: Any]] ?? []).map { contributor in
                InRoomBannerLeadContributor(
                    rank: int(fromAny: contributor["rank"]),
                    score: int(fromAny: contributor["score"]),
                    uid: contributor["uid"] as? String
                )
            }

            return InRoomBannerPlayerState(
                activityCode: base?["activity_code"] as? String,
                featureName: base?["feature_name"] as? String,
                rank: int(fromAny: state?["rank"]),
                score: int(fromAny: state?["score"]),
                stateId: state?["state_id"] as? String,
                uid: state?["uid"] as? String,
                targetRank: int(fromAny: comparison?["target_rank"]),
                targetScore: int(fromAny: comparison?["target_score"]),
                leadContributors: contributors
            )
        }
    }

    private static func extractLinkLayerParticipants(from payload: [String: Any]) -> [LinkLayerParticipant] {
        let userInfoMap = extractLinkLayerUserInfos(from: payload)
        guard let userList = findArray(in: payload, matchingAnyOf: ["userList"]) else { return [] }

        return userList.compactMap { item in
            guard let object = item as? [String: Any] else { return nil }

            let ownerUser = object["ownerUser"] as? [String: Any]
            let nestedUser = ownerUser?["user"] as? [String: Any]
            let userId = string(fromAny: nestedUser?["userId"])
            let info = userId.flatMap { userInfoMap[$0] }

            return LinkLayerParticipant(
                channelId: string(fromAny: object["channelId"]),
                userId: userId,
                displayId: info?["displayId"] as? String,
                nickname: (info?["nickname"] as? String) ?? (nestedUser?["nickname"] as? String),
                status: int(fromAny: object["status"]),
                type: int(fromAny: object["type"]),
                joinTime: string(fromAny: object["joinTime"])
            )
        }
    }

    private static func extractLinkLayerUserInfos(from payload: [String: Any]) -> [String: [String: Any]] {
        guard let allInfos = findDictionary(in: payload, matchingAnyOf: ["userInfos"]) else { return [:] }
        var result: [String: [String: Any]] = [:]

        for (key, value) in allInfos {
            if let object = value as? [String: Any] {
                result[key] = object
            }
        }

        return result
    }

    private static func findDictionary(in value: Any, matchingAnyOf keys: [String]) -> [String: Any]? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let nested = object[key] as? [String: Any] {
                    return nested
                }
            }
            for child in object.values {
                if let nested = findDictionary(in: child, matchingAnyOf: keys) {
                    return nested
                }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let nested = findDictionary(in: item, matchingAnyOf: keys) {
                    return nested
                }
            }
        }

        return nil
    }

    private static func findArray(in value: Any, matchingAnyOf keys: [String]) -> [Any]? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let array = object[key] as? [Any] {
                    return array
                }
            }
            for child in object.values {
                if let array = findArray(in: child, matchingAnyOf: keys) {
                    return array
                }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let nested = findArray(in: item, matchingAnyOf: keys) {
                    return nested
                }
            }
        }

        return nil
    }

    private static func findString(in value: Any, matchingAnyOf keys: [String]) -> String? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let direct = object[key] {
                    if let string = direct as? String, !string.isEmpty { return string }
                    if let number = direct as? NSNumber { return number.stringValue }
                }
            }
            for child in object.values {
                if let string = findString(in: child, matchingAnyOf: keys) { return string }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let string = findString(in: item, matchingAnyOf: keys) { return string }
            }
        }

        return nil
    }

    private static func findInt(in value: Any, matchingAnyOf keys: [String]) -> Int? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let direct = object[key], let int = int(fromAny: direct) { return int }
            }
            for child in object.values {
                if let int = findInt(in: child, matchingAnyOf: keys) { return int }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let int = findInt(in: item, matchingAnyOf: keys) { return int }
            }
        }

        return nil
    }

    private static func int(fromAny value: Any?) -> Int? {
        guard let value else { return nil }
        if let int = value as? Int { return int }
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String, let int = Int(string) { return int }
        return nil
    }

    private static func string(fromAny value: Any?) -> String? {
        guard let value else { return nil }
        if let string = value as? String, !string.isEmpty { return string }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }

    private static func bool(fromAny value: Any?) -> Bool? {
        guard let value else { return nil }
        if let bool = value as? Bool { return bool }
        if let number = value as? NSNumber { return number.boolValue }
        if let string = value as? String {
            switch string.lowercased() {
            case "true", "1": return true
            case "false", "0": return false
            default: return nil
            }
        }
        return nil
    }

    private static func findBool(in value: Any, matchingAnyOf keys: [String]) -> Bool? {
        if let object = value as? [String: Any] {
            for key in keys {
                if let direct = object[key], let bool = bool(fromAny: direct) {
                    return bool
                }
            }
            for child in object.values {
                if let bool = findBool(in: child, matchingAnyOf: keys) { return bool }
            }
        }

        if let array = value as? [Any] {
            for item in array {
                if let bool = findBool(in: item, matchingAnyOf: keys) { return bool }
            }
        }

        return nil
    }
}
