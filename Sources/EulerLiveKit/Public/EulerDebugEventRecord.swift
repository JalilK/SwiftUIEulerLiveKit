import Foundation

public struct EulerDebugEventRecord: Sendable, Equatable, Hashable, Identifiable {
    public var id: String {
        "\(receivedAt.timeIntervalSince1970)-\(eventName)-\(rawPayload)"
    }

    public let eventName: String
    public let rawPayload: String
    public let decodedTypedEvent: EulerLiveEvent?
    public let decodeOutcome: EulerDecodeOutcome
    public let receivedAt: Date

    public init(
        eventName: String,
        rawPayload: String,
        decodedTypedEvent: EulerLiveEvent?,
        decodeOutcome: EulerDecodeOutcome,
        receivedAt: Date
    ) {
        self.eventName = eventName
        self.rawPayload = rawPayload
        self.decodedTypedEvent = decodedTypedEvent
        self.decodeOutcome = decodeOutcome
        self.receivedAt = receivedAt
    }
}
