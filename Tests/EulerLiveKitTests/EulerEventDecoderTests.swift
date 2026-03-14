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
    func decodesObservedGiftEnvelopeStreakFinished() {
        let payload = #"{"messages":[{"type":"WebcastGiftMessage","data":{"repeatCount":1,"comboCount":1,"common":{"method":"WebcastGiftMessage","roomId":"7617156681859975956","describe":"Maya: gifted the host 1 Rose","displayText":{"defaultPattern":"{0:user} sent {1:gift} × {2:string}"}},"giftId":5655,"user":{"userId":"7535293805101057025","uniqueId":"maya57547","nickname":"Maya"},"repeatEnd":1,"groupId":"1773511424704","giftDetails":{"id":"5655","giftName":"Rose","giftType":1,"diamondCount":1,"combo":true,"forLinkMic":true}}}],"timestamp":1773511429572}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "gift")
        #expect(record.decodeOutcome == .decoded)

        guard case .gift(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected gift event")
            return
        }

        #expect(event.uniqueId == "maya57547")
        #expect(event.nickname == "Maya")
        #expect(event.giftName == "Rose")
        #expect(event.giftId == 5655)
        #expect(event.repeatCount == 1)
        #expect(event.repeatEnd == true)
        #expect(event.giftType == 1)
        #expect(event.displayText == "Maya: gifted the host 1 Rose")
        #expect(event.groupId == "1773511424704")
        #expect(event.comboCount == 1)
        #expect(event.diamondCount == 1)
    }

    @Test
    func decodesObservedRoomMessageEnvelope() {
        let payload = #"{"messages":[{"data":{"common":{"isShowMsg":true,"displayText":{"defaultPattern":"Some comments in this LIVE were filtered to protect the community’s experience."},"roomId":"7617156681859975956","msgId":"7617158711178119966","createTime":"1773508034","method":"WebcastRoomMessage"},"content":" ","source":"1","scene":0,"isWelcome":false,"showDurationMs":"0","supportLandscape":false},"type":"WebcastRoomMessage"}],"timestamp":1773511421247}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "room_message")
        #expect(record.decodeOutcome == .decoded)

        guard case .roomMessage(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected room message event")
            return
        }

        #expect(event.content == " ")
        #expect(event.source == "1")
        #expect(event.scene == 0)
        #expect(event.displayText == "Some comments in this LIVE were filtered to protect the community’s experience.")
    }

    @Test
    func decodesObservedLikeEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastLikeMessage","data":{"common":{"method":"WebcastLikeMessage","roomId":"7617138631244909342","displayText":{"defaultPattern":"{0:user} liked the LIVE"}},"user":{"userId":"7266178225680434222","uniqueId":"brayden_bergie","nickname":"Brayden"},"count":"15","totalLikeCount":"48523"}}],"timestamp":1773505623740}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "like")
        #expect(record.decodeOutcome == .decoded)

        guard case .like(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected like event")
            return
        }

        #expect(event.uniqueId == "brayden_bergie")
        #expect(event.nickname == "Brayden")
        #expect(event.likeCount == 15)
        #expect(event.totalLikeCount == 48523)
        #expect(event.displayText == "{0:user} liked the LIVE")
    }

    @Test
    func decodesObservedCaptionEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastCaptionMessage","data":{"common":{"method":"WebcastCaptionMessage","roomId":"7617138631244909342"},"timestampMs":"1773506671174","durationMs":"1000","content":[{"lang":"en","content":"that crazy."}],"sentenceId":"1773506671174","sequenceId":"1773506671174","definite":true}}],"timestamp":1773506670116}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "caption_message")
        #expect(record.decodeOutcome == .decoded)

        guard case .caption(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected caption event")
            return
        }

        #expect(event.roomId == "7617138631244909342")
        #expect(event.timestampMs == 1773506671174)
        #expect(event.durationMs == 1000)
        #expect(event.lines.count == 1)
        #expect(event.lines.first?.language == "en")
        #expect(event.lines.first?.content == "that crazy.")
    }

    @Test
    func decodesObservedBarrageEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastBarrageMessage","data":{"common":{"method":"WebcastBarrageMessage","roomId":"7617107657484225293"},"msgType":9,"duration":"4000","content":{"defaultPattern":"joined"},"user":{"userId":"6897434814581818374","uniqueId":"fan_entrance","nickname":"Fan Entrance"}}}],"timestamp":1773501595974}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "barrage")
        #expect(record.decodeOutcome == .decoded)

        guard case .barrage(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected barrage event")
            return
        }

        #expect(event.roomId == "7617107657484225293")
        #expect(event.messageType == 9)
        #expect(event.durationMs == 4000)
        #expect(event.displayText == "joined")
        #expect(event.userId == "6897434814581818374")
        #expect(event.uniqueId == "fan_entrance")
        #expect(event.nickname == "Fan Entrance")
    }

    @Test
    func decodesObservedLinkMicFanTicketEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastLinkMicFanTicketMethod","data":{"common":{"method":"WebcastLinkMicFanTicketMethod","roomId":"7617138631244909342"},"FanTicketRoomNotice":{"UserFanTicketList":[{"UserId":"7499243542570419243","FanTicket":"57","MatchTotalScore":"0","MatchRank":0}],"TotalLinkMicFanTicket":"57","MatchId":"0","EventTime":"1773506649867","playId":"0","playScene":0}}}],"timestamp":1773506670116}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "link_mic_fan_ticket_method")
        #expect(record.decodeOutcome == .decoded)

        guard case .linkMicFanTicket(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected link mic fan ticket event")
            return
        }

        #expect(event.roomId == "7617138631244909342")
        #expect(event.totalLinkMicFanTicket == 57)
        #expect(event.users.count == 1)
        #expect(event.users.first?.userId == "7499243542570419243")
        #expect(event.users.first?.fanTicket == 57)
    }

    @Test
    func decodesObservedLinkMicArmiesEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastLinkMicArmies","data":{"common":{"method":"WebcastLinkMicArmies","roomId":"7617156681859975956"},"battleId":"7617174402200554261","channelId":"7617164558465878805","battleStatus":1,"fromUserId":"7329616845265339397","giftId":"5879","giftCount":0,"totalDiamondCount":0,"repeatCount":0,"scoreUpdateTime":"1773511789916","giftSentTime":"1773511789795","battleItems":{"7055026438022808581":{"userArmy":[{"userId":"6959375908424418309","score":"250","nickname":"virgobeast♤aka Harold","diamondScore":"0","userIdStr":"6959375908424418309"}],"hostScore":"268","anchorIdStr":"7055026438022808581"},"6765684109357728774":{"userArmy":[{"userId":"7329616845265339397","score":"95","nickname":"💎❤kelvin ⚾️❤⚾️💎💎kristal💎❤","diamondScore":"0","userIdStr":"7329616845265339397"},{"userId":"6837466029536019461","score":"64","nickname":"Ebenezer Cerda Gomez","diamondScore":"0","userIdStr":"6837466029536019461"}],"hostScore":"259","anchorIdStr":"6765684109357728774"}}}}],"timestamp":1773511791099}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "link_mic_armies")
        #expect(record.decodeOutcome == .decoded)

        guard case .linkMicArmies(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected link mic armies event")
            return
        }

        #expect(event.roomId == "7617156681859975956")
        #expect(event.battleId == "7617174402200554261")
        #expect(event.channelId == "7617164558465878805")
        #expect(event.battleStatus == 1)
        #expect(event.giftId == 5879)
        #expect(event.totalDiamondCount == 0)
        #expect(event.sides.count == 2)
        #expect(event.sides.first(where: { $0.anchorId == "7055026438022808581" })?.hostScore == 268)
        #expect(event.sides.first(where: { $0.anchorId == "6765684109357728774" })?.users.count == 2)
    }
}
