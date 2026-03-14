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
    func decodesObservedGiftEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastGiftMessage","data":{"common":{"displayText":{"defaultPattern":"{0:user} sent {1:gift} × {2:string}"},"describe":"Tracy Merz: gifted the host 1 Rose"},"user":{"userId":"6840933221401625606","uniqueId":"tracymerz","nickname":"Tracy Merz"},"giftId":"5655","giftDetails":{"giftId":"5655","giftName":"Rose","giftType":1},"repeatCount":"1","repeatEnd":true}}],"timestamp":1773501381227}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "gift")
        #expect(record.decodeOutcome == .decoded)

        guard case .gift(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected gift event")
            return
        }

        #expect(event.uniqueId == "tracymerz")
        #expect(event.nickname == "Tracy Merz")
        #expect(event.giftName == "Rose")
        #expect(event.giftId == 5655)
        #expect(event.repeatCount == 1)
        #expect(event.repeatEnd == true)
    }

    @Test
    func decodesObservedRoomMessageEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastRoomMessage","data":{"content":"Room goal updated","source":"system","scene":4,"common":{"displayText":{"defaultPattern":"Room goal updated"}}}}],"timestamp":1773511111000}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "room_message")
        #expect(record.decodeOutcome == .decoded)

        guard case .roomMessage(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected room message event")
            return
        }

        #expect(event.content == "Room goal updated")
        #expect(event.source == "system")
        #expect(event.scene == 4)
    }
}
