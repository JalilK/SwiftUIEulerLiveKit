import Foundation
import SwiftUI
import EulerLiveKit

@MainActor
final class ExampleViewModel: ObservableObject {
    private static let lastSuccessfulUniqueIdDefaultsKey = "EulerLiveExampleApp.lastSuccessfulUniqueId"
    private static let workerBaseURL = "https://euler-token-worker.swiftui-euler-api-key.workers.dev"
    private let userDefaults = UserDefaults.standard

    @Published var uniqueId: String
    @Published var statusHeadline: String = "Idle"
    @Published var statusDetail: String = "Enter a TikTok uniqueId and connect."
    @Published var technicalStatusDetail: String?
    @Published var records: [EulerDebugEventRecord] = []
    @Published var connectionError: String?

    private var client: EulerLiveClient?

    init() {
        uniqueId = userDefaults.string(forKey: Self.lastSuccessfulUniqueIdDefaultsKey) ?? ""
    }

    var tokenEndpointDisplayText: String {
        "\(Self.workerBaseURL)/token"
    }

    var coverage: [EulerDocumentedEventCoverage] {
        EulerEventDecoder.documentedEventCoverage(from: records)
    }

    func connect() {
        connectionError = nil
        technicalStatusDetail = nil
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
        statusHeadline = "Connecting"
        statusDetail = "Requesting a JWT from the worker and opening the Euler WebSocket."

        let configuration = EulerLiveConfiguration(backendBaseURL: backendURL, eventHistoryLimit: 500)
        let client = EulerLiveClient(
            configuration: configuration,
            tokenProvider: BackendTokenService(configuration: configuration)
        )

        client.onStatusChange = { [weak self] status in
            Task { @MainActor in
                guard let self else { return }
                let presentation = Self.presentableStatus(status)
                self.statusHeadline = presentation.headline
                self.statusDetail = presentation.detail
                self.technicalStatusDetail = presentation.technicalDetail

                if case .connected = status {
                    self.userDefaults.set(trimmedUniqueId, forKey: Self.lastSuccessfulUniqueIdDefaultsKey)
                }
            }
        }

        client.onEventRecord = { [weak self] record in
            Task { @MainActor in
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
                    self.statusHeadline = "Connection failed"
                    self.statusDetail = "The app could not establish a usable session."
                    self.technicalStatusDetail = String(describing: error)
                }
            }
        }
    }

    func disconnect() {
        guard let client else { return }
        connectionError = nil
        Task {
            await client.disconnect()
        }
    }

    func clearHistory() {
        records.removeAll()
        client?.clearHistory()
    }

    private static func presentableStatus(_ status: EulerConnectionStatus) -> (headline: String, detail: String, technicalDetail: String?) {
        switch status {
        case .idle:
            return ("Idle", "Enter a TikTok uniqueId and connect.", nil)
        case .fetchingToken:
            return ("Fetching token", "Requesting a short-lived JWT from the worker.", nil)
        case .connecting:
            return ("Connecting", "Opening the Euler WebSocket.", nil)
        case .connected(let roomInfo):
            if let roomInfo {
                let name = roomInfo.nickname ?? roomInfo.uniqueId ?? "creator"
                let viewers = roomInfo.currentViewers.map { " with \($0) viewers" } ?? ""
                return ("Connected", "Live session active for \(name)\(viewers).", nil)
            }
            return ("Connected", "Socket is open and waiting for room metadata.", nil)
        case .disconnected(let reason):
            return (
                reason.userFacingTitle,
                reason.userFacingMessage,
                reason.isExpectedUserAction ? nil : reason.description
            )
        case .failed(let error):
            return ("Connection failed", error.description, error.description)
        }
    }
}
