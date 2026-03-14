import Testing
@testable import EulerLiveKit
import Foundation

struct EulerUnknownPayloadSinkTests {
    @Test
    func schemaFingerprintIgnoresValueChanges() {
        let payloadA = #"{"timestamp":1,"messages":[{"type":"WebcastMysteryMessage","data":{"common":{"roomId":"1"},"score":"10","user":{"id":"abc"}}}]}"#
        let payloadB = #"{"timestamp":2,"messages":[{"type":"WebcastMysteryMessage","data":{"common":{"roomId":"999"},"score":"999","user":{"id":"xyz"}}}]}"#

        let fingerprintA = EulerUnknownPayloadSink.schemaFingerprint(fromRawPayload: payloadA)
        let fingerprintB = EulerUnknownPayloadSink.schemaFingerprint(fromRawPayload: payloadB)

        #expect(fingerprintA == fingerprintB)

        let paths = EulerUnknownPayloadSink.schemaPaths(fromRawPayload: payloadA) ?? []

        #expect(paths.contains("messages[].type"))
        #expect(paths.contains("messages[].data.common.roomId"))
        #expect(paths.contains("messages[].data.score"))
        #expect(paths.contains("messages[].data.user.id"))
    }

    @Test
    func sinkDedupesSameSchemaWithinEventFamily() async {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sink = EulerUnknownPayloadSink(baseDirectoryURL: directory)

        let payloadA = #"{"timestamp":1,"messages":[{"type":"WebcastMysteryMessage","data":{"common":{"roomId":"1"},"score":"10","user":{"id":"abc"}}}]}"#
        let payloadB = #"{"timestamp":2,"messages":[{"type":"WebcastMysteryMessage","data":{"common":{"roomId":"2"},"score":"99","user":{"id":"xyz"}}}]}"#

        let recordA = EulerEventDecoder.decodeRecord(from: payloadA)
        let recordB = EulerEventDecoder.decodeRecord(from: payloadB)

        await sink.captureIfNeeded(record: recordA)
        await sink.captureIfNeeded(record: recordB)

        let entries = await sink.manifestEntries(for: recordA.eventName)

        #expect(entries.count == 1)
        #expect(entries.first?.recordCount == 2)
        #expect(entries.first?.primaryMessageTypes == ["WebcastMysteryMessage"])
        #expect((entries.first?.representativeFileName.isEmpty) == false)
    }
}
