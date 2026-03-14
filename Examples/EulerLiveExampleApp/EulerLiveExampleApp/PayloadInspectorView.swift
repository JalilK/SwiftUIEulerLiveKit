import SwiftUI
import EulerLiveKit

struct PayloadInspectorView: View {
    let record: EulerDebugEventRecord

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Event Name", value: record.eventName)
                LabeledContent("Decode Outcome", value: record.decodeOutcome.rawValue)
                LabeledContent("Received At", value: timestampText)
                if let summary = record.decodedTypedEvent?.summary {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Typed Summary")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(summary)
                            .font(.footnote.monospaced())
                            .textSelection(.enabled)
                    }
                }
            }

            Section("Raw Payload") {
                ScrollView(.horizontal) {
                    Text(prettyPayload)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle(record.eventName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var timestampText: String {
        record.receivedAt.formatted(date: .abbreviated, time: .standard)
    }

    private var prettyPayload: String {
        guard let data = record.rawPayload.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: prettyData, encoding: .utf8) else {
            return record.rawPayload
        }
        return string
    }
}
