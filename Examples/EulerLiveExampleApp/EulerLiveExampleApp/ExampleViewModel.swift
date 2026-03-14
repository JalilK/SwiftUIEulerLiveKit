import Foundation
import SwiftUI
import EulerLiveKit

@MainActor
final class ExampleViewModel: ObservableObject {
    private static let lastSuccessfulUniqueIdDefaultsKey = "EulerLiveExampleApp.lastSuccessfulUniqueId"
    private static let workerBaseURL = "https://euler-token-worker.swiftui-euler-api-key.workers.dev"
    private let userDefaults = UserDefaults.standard

    @Published var uniqueId: String
    @Published var statusText: String = "idle"
    @Published var records: [EulerDebugEventRecord] = []
    @Published var connectionError: String?

    private var client: EulerLiveClient?

    init() {
        uniqueId = userDefaults.string(forKey: Self.lastSuccessfulUniqueIdDefaultsKey) ?? ""
    }

    var tokenEndpointDisplayText: String {
        "\(Self.workerBaseURL)/token"
    }

    func connect() {
        connectionError = nil
        records.removeAll()

        let trimmedUniqueId = uniqueId.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let backendURL = URL(string: Self.workerBaseURL) else {
            connectionError = "Invalid built-in Worker URL"
            return
        }

        guard !trimmedUniqueId.isEmpty else {
            connectionError = "TikTok uniqueId is required"
            return
        }

        uniqueId = trimmedUniqueId

        let configuration = EulerLiveConfiguration(backendBaseURL: backendURL, eventHistoryLimit: 500)
        let client = EulerLiveClient(
            configuration: configuration,
            tokenProvider: BackendTokenService(configuration: configuration)
        )

        client.onStatusChange = { [weak self] status in
            Task { @MainActor in
                guard let self else { return }
                self.statusText = Self.describe(status)

                if case .connected = status {
                    self.userDefaults.set(trimmedUniqueId, forKey: Self.lastSuccessfulUniqueIdDefaultsKey)
                }
            }
        }

        client.onEventRecord = { [weak self] record in
            Task { @MainActor in
                EulerConsolePayloadPrinter.printLogBlock(for: record)
                self?.records.insert(record, at: 0)
            }
        }

        self.client = client

        Task {
            do {
                try await client.connect(to: trimmedUniqueId)
            } catch {
                await MainActor.run {
                    self.connectionError = String(describing: error)
                }
            }
        }
    }

    func disconnect() {
        guard let client else { return }
        Task {
            await client.disconnect()
        }
    }

    func clearHistory() {
        records.removeAll()
        client?.clearHistory()
    }

    private static func describe(_ status: EulerConnectionStatus) -> String {
        switch status {
        case .idle:
            return "idle"
        case .fetchingToken:
            return "fetchingToken"
        case .connecting:
            return "connecting"
        case .connected(let roomInfo):
            if let roomInfo {
                return "connected roomId=\(roomInfo.roomId ?? "nil") uniqueId=\(roomInfo.uniqueId ?? "nil")"
            }
            return "connected"
        case .disconnected(let reason):
            return "disconnected \(reason.description)"
        case .failed(let error):
            return "failed \(error.description)"
        }
    }
}
