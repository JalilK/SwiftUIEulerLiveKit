import Testing
@testable import EulerLiveKit
import Foundation

struct EulerEventDecoderTests {
    @Test
    func decodeRecordsFansOutMultiMessageEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastChatMessage","data":{"user":{"uniqueId":"alice","nickname":"Alice"},"comment":"hello"}},{"type":"WebcastRoomMessage","data":{"content":"system text","source":"system","scene":1}}],"timestamp":1773509999000}"#

        let records = EulerEventDecoder.decodeRecords(from: payload)

        #expect(records.count == 2)
        #expect(records[0].eventName == "chat")
        #expect(records[1].eventName == "room_message")

        guard case .comment(let chatEvent)? = records[0].decodedTypedEvent else {
            Issue.record("Expected first record to be chat")
            return
        }
        #expect(chatEvent.uniqueId == "alice")
        #expect(chatEvent.comment == "hello")

        guard case .roomMessage(let roomEvent)? = records[1].decodedTypedEvent else {
            Issue.record("Expected second record to be room_message")
            return
        }
        #expect(roomEvent.content == "system text")
        #expect(roomEvent.source == "system")
        #expect(roomEvent.scene == 1)
    }

    @Test
    func decodesObservedGiftEnvelopeStreakInProgress() {
        let payload = #"{"messages":[{"type":"WebcastGiftMessage","data":{"repeatCount":1,"comboCount":1,"common":{"method":"WebcastGiftMessage","roomId":"7617156681859975956","describe":"Ebenezer Cerda Gomez: gifted the host 1 Rose","displayText":{"defaultPattern":"{0:user} sent {1:gift} × {2:string}"}},"giftId":5655,"user":{"userId":"6837466029536019461","uniqueId":"ebengomez7","nickname":"Ebenezer Cerda Gomez"},"repeatEnd":0,"groupId":"1773511422618","giftDetails":{"id":"5655","giftName":"Rose","giftType":1,"diamondCount":1,"combo":true,"forLinkMic":true}}}],"timestamp":1773511423909}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "gift")
        #expect(record.decodeOutcome == .decoded)

        guard case .gift(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected gift event")
            return
        }

        #expect(event.uniqueId == "ebengomez7")
        #expect(event.nickname == "Ebenezer Cerda Gomez")
        #expect(event.giftName == "Rose")
        #expect(event.giftId == 5655)
        #expect(event.repeatCount == 1)
        #expect(event.repeatEnd == false)
        #expect(event.giftType == 1)
        #expect(event.displayText == "Ebenezer Cerda Gomez: gifted the host 1 Rose")
        #expect(event.groupId == "1773511422618")
        #expect(event.comboCount == 1)
        #expect(event.diamondCount == 1)
    }

    @Test
    func decodesObservedLinkMicMethodEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastLinkMicMethod","data":{"common":{"method":"WebcastLinkMicMethod","roomId":"7617156681859975956"},"messageType":8,"userId":"6765684109357728774","fanTicket":"2744","totalLinkMicFanTicket":"2744","channelId":"0","anchorLinkmicId":"0","matchType":0,"win":false,"rivalAnchorId":"0","shouldShowPopup":false,"rtcJoinChannel":false}}],"timestamp":1773515238532}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "link_mic_method")
        #expect(record.decodeOutcome == .decoded)

        guard case .linkMicMethod(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected link mic method event")
            return
        }

        #expect(event.roomId == "7617156681859975956")
        #expect(event.messageType == 8)
        #expect(event.userId == "6765684109357728774")
        #expect(event.fanTicket == 2744)
        #expect(event.totalLinkMicFanTicket == 2744)
        #expect(event.channelId == "0")
        #expect(event.anchorLinkMicId == "0")
        #expect(event.matchType == 0)
        #expect(event.win == false)
    }

    @Test
    func decodesObservedGoalUpdateEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastGoalUpdateMessage","data":{"indicator":{"key":"live_goal_indicator_stream_goal","op":3},"goal":{"id":"7617154908760951572","description":"Goal description","type":1,"status":2,"contributors":[{"userId":"7471766080148505643","score":"2151","userIdStr":"7471766080148505643","inRoom":false,"isFriend":true,"displayId":"Top Fan"}],"subGoals":[{"target":"15","source":0,"id":"7934","gift":{"name":"Heart Me","diamondCount":"1","type":4},"idStr":"7934","type":1,"progress":"14"}]},"contributorDisplayId":"Top Fan","contributeScore":"1","updateSource":2,"contributorId":"7471766080148505643","contributorIdStr":"7471766080148505643","contributeCount":"1","common":{"method":"WebcastGoalUpdateMessage","roomId":"7617156681859975956"},"pin":false,"unpin":false}}],"timestamp":1773515237788}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "goal_update")
        #expect(record.decodeOutcome == .decoded)

        guard case .goalUpdate(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected goal update event")
            return
        }

        #expect(event.roomId == "7617156681859975956")
        #expect(event.goalId == "7617154908760951572")
        #expect(event.goalDescription == "Goal description")
        #expect(event.goalType == 1)
        #expect(event.goalStatus == 2)
        #expect(event.indicatorKey == "live_goal_indicator_stream_goal")
        #expect(event.indicatorOperation == 3)
        #expect(event.contributorDisplayId == "Top Fan")
        #expect(event.contributeScore == 1)
        #expect(event.subGoals.count == 1)
        #expect(event.contributors.count == 1)
        #expect(event.subGoals.first?.giftName == "Heart Me")
    }

    @Test
    func decodesObservedInRoomBannerEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastInRoomBannerMessage","data":{"common":{"method":"WebcastInRoomBannerMessage","roomId":"7617156681859975956"},"data":"{\"activity_indicator\":{\"currents\":[{\"activity_code\":\"activity-1\",\"now\":1773515237,\"phase_name\":null}],\"user_rank__player_state\":[{\"base\":{\"activity_code\":\"activity-1\",\"feature_name\":\"feature-1\"},\"state\":{\"comparison\":{\"target_rank\":99,\"target_score\":\"1210734\"},\"lead_contributors\":[{\"rank\":1,\"score\":\"2993\",\"uid\":\"7471766080148505643\"}],\"rank\":0,\"score\":\"8637\",\"state_id\":\"6765684109357728774\",\"uid\":\"6765684109357728774\"}}]}}","position":0,"actionType":0}}],"timestamp":1773515245887}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "in_room_banner")
        #expect(record.decodeOutcome == .decoded)

        guard case .inRoomBanner(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected in room banner event")
            return
        }

        #expect(event.roomId == "7617156681859975956")
        #expect(event.position == 0)
        #expect(event.actionType == 0)
        #expect(event.currents.count == 1)
        #expect(event.playerStates.count == 1)
        #expect(event.playerStates.first?.activityCode == "activity-1")
        #expect(event.playerStates.first?.leadContributors.first?.uid == "7471766080148505643")
    }

    @Test
    func decodesObservedLinkLayerEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastLinkLayerMessage","data":{"common":{"method":"WebcastLinkLayerMessage","roomId":"7617156681859975956"},"scene":2,"channelId":"7617156681859975956","source":"SOURCE_TYPE_RECOMMENDED_FRIEND_CAPULE","groupChangeContent":{"groupUser":{"userList":[{"status":1,"channelId":"7617156681859975956","joinTime":"1773515532113000000","ownerUser":{"channelId":"7617191096896064257","user":{"userId":"6765684109357728774","nickname":""}},"type":102}]}},"messageType":18,"rtcRoomId":"0","businessContent":{"cohostContent":{"listChangeBizContent":{"userInfos":{"6765684109357728774":{"displayId":"alexiselclasico","nickname":"乇𝓵 c𝓵ªŝіcᵒ🎸"}}}}}}}],"timestamp":1773515533457}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "link_layer")
        #expect(record.decodeOutcome == .decoded)

        guard case .linkLayer(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected link layer event")
            return
        }

        #expect(event.roomId == "7617156681859975956")
        #expect(event.scene == 2)
        #expect(event.messageType == 18)
        #expect(event.channelId == "7617156681859975956")
        #expect(event.source == "SOURCE_TYPE_RECOMMENDED_FRIEND_CAPULE")
        #expect(event.participants.count == 1)
        #expect(event.participants.first?.userId == "6765684109357728774")
        #expect(event.participants.first?.displayId == "alexiselclasico")
        #expect(event.participants.first?.status == 1)
        #expect(event.participants.first?.type == 102)
    }
}
