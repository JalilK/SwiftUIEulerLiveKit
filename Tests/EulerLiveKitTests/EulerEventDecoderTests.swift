import Testing
@testable import EulerLiveKit
import Foundation

struct EulerEventDecoderTests {
    @Test
    func preservesRawPayloadForKnownGiftEvent() {
        let payload = #"{"eventName":"gift","user":{"uniqueId":"alice","nickname":"Alice"},"gift":{"giftId":7,"giftName":"Rose"},"repeatCount":3}"#
        let record = EulerEventDecoder.decodeRecord(from: payload, receivedAt: Date(timeIntervalSince1970: 123))

        #expect(record.eventName == "gift")
        #expect(record.rawPayload == payload)
        #expect(record.decodeOutcome == .decoded)
        #expect(record.receivedAt == Date(timeIntervalSince1970: 123))

        guard case .gift(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected gift event")
            return
        }
        #expect(event.uniqueId == "alice")
        #expect(event.nickname == "Alice")
        #expect(event.giftId == 7)
        #expect(event.giftName == "Rose")
        #expect(event.repeatCount == 3)
    }

    @Test
    func classifiesUnknownEventButStillPreservesRawPayload() {
        let payload = #"{"eventName":"mystery_event","foo":"bar"}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "mystery_event")
        #expect(record.rawPayload == payload)
        #expect(record.decodeOutcome == .unknownEvent)
        #expect(record.decodedTypedEvent == .unknown(eventName: "mystery_event"))
    }

    @Test
    func marksInvalidJson() {
        let payload = #"{"eventName":"gift""#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "invalid_payload")
        #expect(record.decodeOutcome == .invalidJSON)
        #expect(record.decodedTypedEvent == nil)
        #expect(record.rawPayload == payload)
    }

    @Test
    func roomInfoFallsBackWhenNoExplicitEventNameExists() {
        let payload = #"{"roomId":"12345","owner":{"uniqueId":"tv_asahi_news","nickname":"TV Asahi"}}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "room_info")
        #expect(record.decodeOutcome == .decoded)
        guard case .roomInfo(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected room info event")
            return
        }
        #expect(event.roomId == "12345")
        #expect(event.uniqueId == "tv_asahi_news")
        #expect(event.nickname == "TV Asahi")
    }
}
