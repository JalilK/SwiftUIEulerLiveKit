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
        #expect(event.displayText == "{0:user} sent {1:gift} × {2:string}")
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
        #expect(event.displayText == "{0:user} sent {1:gift} × {2:string}")
    }
}
