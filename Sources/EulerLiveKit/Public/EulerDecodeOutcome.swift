import Foundation

public enum EulerDecodeOutcome: String, Sendable, Equatable, Codable {
    case decoded
    case decodedWithPartialData
    case unknownEvent
    case invalidJSON
    case unsupportedPayload
}
