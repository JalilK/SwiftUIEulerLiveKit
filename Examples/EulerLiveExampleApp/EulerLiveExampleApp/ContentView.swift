import SwiftUI
import EulerLiveKit

struct ContentView: View {
    @StateObject private var viewModel = ExampleViewModel()

    var body: some View {
        NavigationStack {
            List {
                connectionSection
                coverageSection
                latestEventSection
                historySection
            }
            .navigationTitle("EulerLiveKit Debug")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        viewModel.clearHistory()
                    }
                    .disabled(viewModel.records.isEmpty)
                }
            }
        }
    }

    private var connectionSection: some View {
        Section("Connection") {
            VStack(alignment: .leading, spacing: 6) {
                Text("Token Endpoint")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.tokenEndpointDisplayText)
                    .font(.footnote.monospaced())
                    .textSelection(.enabled)
                Text("This debug app uses the deployed Cloudflare Worker token route by default.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TextField("TikTok uniqueId", text: $viewModel.creatorInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.body.monospaced())
                .submitLabel(.go)

            Text("The app remembers the last creator that connected successfully.")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.statusHeadline)
                    .font(.headline)
                Text(viewModel.statusDetail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let technicalStatusDetail = viewModel.technicalStatusDetail {
                    DisclosureGroup("Technical Details") {
                        Text(technicalStatusDetail)
                            .font(.footnote.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(.vertical, 4)

            HStack {
                Button("Connect") {
                    viewModel.connect()
                }
                .buttonStyle(.borderedProminent)

                Button("Disconnect") {
                    viewModel.disconnect()
                }
                .buttonStyle(.bordered)
            }

            if let connectionError = viewModel.connectionError {
                Text(connectionError)
                    .font(.footnote.monospaced())
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        }
    }

    private var coverageSection: some View {
        Section("Documented Event Coverage") {
            if viewModel.records.isEmpty {
                Text("Connect and capture events to see which TikTokLive Connector models already map to concrete native types.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.coverage, id: \.event) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.event.displayName)
                                .font(.headline)
                            Spacer()
                            Text(item.implemented ? "implemented" : "not implemented")
                                .font(.caption.monospaced())
                                .foregroundStyle(item.implemented ? .green : .orange)
                        }
                        Text("observed payloads \(item.observedRecordCount)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                        if item.observedPayloadTypes.isEmpty {
                            Text("No matching payloads captured yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(item.observedPayloadTypes.joined(separator: ", "))
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var latestEventSection: some View {
        Section("Latest Event") {
            if let latestRecord = viewModel.records.first {
                NavigationLink {
                    PayloadInspectorView(record: latestRecord)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(latestRecord.eventName)
                            .font(.headline)
                        Text(latestRecord.decodeOutcome.rawValue)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                        if let typedSummary = latestRecord.decodedTypedEvent?.summary {
                            Text(typedSummary)
                                .font(.footnote.monospaced())
                                .lineLimit(2)
                        }
                    }
                }
            } else {
                Text("No events received yet")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var historySection: some View {
        Section("Event History") {
            if viewModel.records.isEmpty {
                Text("Connect to a stream to inspect inbound payloads")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.records) { record in
                    NavigationLink {
                        PayloadInspectorView(record: record)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(record.eventName)
                                .font(.headline)
                            Text(record.decodeOutcome.rawValue)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                            Text(record.receivedAt.formatted(date: .omitted, time: .standard))
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                            if let typedSummary = record.decodedTypedEvent?.summary {
                                Text(typedSummary)
                                    .font(.footnote.monospaced())
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}
