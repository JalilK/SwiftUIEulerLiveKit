import Foundation

public enum EulerConsolePayloadPrinter {
    public static func makeLogBlock(for record: EulerDebugEventRecord) -> String {
        let timestamp = ISO8601DateFormatter().string(from: record.receivedAt)

        return [
            "EULERSTREAM_EVENT_BEGIN",
            "event_name=\(record.eventName)",
            "decode_outcome=\(record.decodeOutcome.rawValue)",
            "received_at=\(timestamp)",
            "raw_payload:",
            record.rawPayload,
            "EULERSTREAM_EVENT_END"
        ].joined(separator: "\n")
    }

    public static func printLogBlock(for record: EulerDebugEventRecord) {
        Swift.print(makeLogBlock(for: record))
    }
}
