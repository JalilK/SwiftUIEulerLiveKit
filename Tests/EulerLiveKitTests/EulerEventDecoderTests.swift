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
    func decodesObservedRoomInfoEnvelope() {
        let payload = #"{"messages":[{"type":"roomInfo","data":{"roomInfo":{"id":"7617107657484225293","isLive":true,"currentViewers":1604,"totalViewers":1598,"title":"TikTok Shop BFCM"},"user":{"avatarUrl":"https://example.com/avatar.webp","nickname":"Dude Dealz","uniqueId":"dudedealz"},"uniqueId":"dudedealz"}}],"timestamp":1773501365349}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "room_info")
        #expect(record.decodeOutcome == .decoded)

        guard case .roomInfo(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected room info event")
            return
        }

        #expect(event.roomId == "7617107657484225293")
        #expect(event.uniqueId == "dudedealz")
        #expect(event.nickname == "Dude Dealz")
        #expect(event.currentViewers == 1604)
        #expect(event.title == "TikTok Shop BFCM")
    }

    @Test
    func decodesObservedChatEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastChatMessage","data":{"user":{"userId":"7221594907843806254","uniqueId":"mohonii789","nickname":"MoHonii789"},"comment":"1-year warranty covers most parts; message seller Aovopro for assistance","userIdentity":{"isModeratorOfAnchor":true,"isFollowerOfAnchor":true}}}],"timestamp":1773501368000}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "chat")
        #expect(record.decodeOutcome == .decoded)

        guard case .comment(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected comment event")
            return
        }

        #expect(event.uniqueId == "mohonii789")
        #expect(event.userId == "7221594907843806254")
        #expect(event.comment == "1-year warranty covers most parts; message seller Aovopro for assistance")
        #expect(event.isModerator == true)
        #expect(event.isFollowerOfAnchor == true)
    }

    @Test
    func decodesObservedMemberEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastMemberMessage","data":{"user":{"userId":"7565211967515018253","uniqueId":"richard_nasti","nickname":"RICHARD NASTI"},"memberCount":1629}}],"timestamp":1773501545601}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "member")
        #expect(record.decodeOutcome == .decoded)

        guard case .member(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected member event")
            return
        }

        #expect(event.uniqueId == "richard_nasti")
        #expect(event.nickname == "RICHARD NASTI")
        #expect(event.viewerCount == 1629)
    }

    @Test
    func decodesObservedRoomUserEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastRoomUserSeqMessage","data":{"viewerCount":1629,"ranksList":[{"coinCount":104,"user":{"uniqueId":"ugcdorisb","nickname":"ugcdorisb"}}]}}],"timestamp":1773501514060}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "room_user")
        #expect(record.decodeOutcome == .decoded)

        guard case .roomUser(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected room user event")
            return
        }

        #expect(event.viewerCount == 1629)
        #expect(event.topGifterUniqueId == "ugcdorisb")
        #expect(event.topGifterCoinCount == 104)
    }

    @Test
    func decodesObservedFollowSocialEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastSocialMessage","data":{"common":{"displayText":{"defaultPattern":"{0:user} followed the LIVE creator"}},"user":{"userId":"6712228768397870085","uniqueId":"xavierpenguin","nickname":"Xavier"},"action":"1","followCount":36845,"shareCount":0}}],"timestamp":1773505697141}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "follow")
        #expect(record.decodeOutcome == .decoded)

        guard case .follow(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected follow event")
            return
        }

        #expect(event.userId == nil)
        #expect(event.uniqueId == "xavierpenguin")
        #expect(event.nickname == "Xavier")
        #expect(event.followerCount == 36845)
    }

    @Test
    func decodesObservedShareSocialEnvelope() {
        let payload = #"{"messages":[{"type":"WebcastSocialMessage","data":{"common":{"displayText":{"defaultPattern":"{0:user} shared the LIVE"}},"user":{"userId":"7039496064566723589","uniqueId":"ralphbryant3","nickname":"ralphbryant3"},"action":"3","followCount":0,"shareCount":36}}],"timestamp":1773505883849}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "share")
        #expect(record.decodeOutcome == .decoded)

        guard case .share(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected share event")
            return
        }

        #expect(event.uniqueId == "ralphbryant3")
        #expect(event.nickname == "ralphbryant3")
        #expect(event.shareCount == 36)
    }

    @Test
    func decodesWorkerInfoEnvelope() {
        let payload = #"{"messages":[{"type":"workerInfo","data":{"isLoggedIn":false,"webSocketId":"49390ba9-2016-48d3-b6ee-fb0a78107653","schemaVersion":"v2","features":{"bundleEvents":true,"rawMessages":false}}}],"timestamp":1773501365349}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "worker_info")
        #expect(record.decodeOutcome == .decoded)

        guard case .workerInfo(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected worker info event")
            return
        }

        #expect(event.schemaVersion == "v2")
        #expect(event.bundleEvents == true)
        #expect(event.rawMessages == false)
    }

    @Test
    func decodesTransportConnectEnvelope() {
        let payload = #"{"messages":[{"type":"tiktok.connect","data":{"agentId":"sign-agent-14"}}],"timestamp":1773501367668}"#
        let record = EulerEventDecoder.decodeRecord(from: payload)

        #expect(record.eventName == "tiktok.connect")
        #expect(record.decodeOutcome == .decoded)

        guard case .transportConnect(let event)? = record.decodedTypedEvent else {
            Issue.record("Expected transport connect event")
            return
        }

        #expect(event.agentId == "sign-agent-14")
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
