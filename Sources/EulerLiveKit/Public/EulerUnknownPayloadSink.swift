import Foundation
import CryptoKit

public struct EulerUnknownPayloadManifestEntry: Codable, Sendable, Equatable {
    public let eventName: String
    public let fingerprint: String
    public let schemaPaths: [String]
    public var recordCount: Int
    public var firstSeenAt: Date
    public var lastSeenAt: Date
    public let representativeFileName: String
    public var primaryMessageTypes: [String]

    public init(
        eventName: String,
        fingerprint: String,
        schemaPaths: [String],
        recordCount: Int,
        firstSeenAt: Date,
        lastSeenAt: Date,
        representativeFileName: String,
        primaryMessageTypes: [String]
    ) {
        self.eventName = eventName
        self.fingerprint = fingerprint
        self.schemaPaths = schemaPaths
        self.recordCount = recordCount
        self.firstSeenAt = firstSeenAt
        self.lastSeenAt = lastSeenAt
        self.representativeFileName = representativeFileName
        self.primaryMessageTypes = primaryMessageTypes
    }
}

public actor EulerUnknownPayloadSink {
    private let baseDirectoryURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(baseDirectoryURL: URL, fileManager: FileManager = .default) {
        self.baseDirectoryURL = baseDirectoryURL
        self.fileManager = fileManager

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func captureIfNeeded(record: EulerDebugEventRecord) async {
        guard Self.shouldCapture(record) else { return }
        try? capture(record: record)
    }

    public func manifestEntries(for eventName: String) async -> [EulerUnknownPayloadManifestEntry] {
        let safeEventName = Self.safePathComponent(eventName)
        return (try? loadManifest(for: safeEventName)) ?? []
    }

    public static func schemaPaths(fromRawPayload rawPayload: String) -> [String]? {
        guard let object = jsonObject(fromRawPayload: rawPayload) else { return nil }
        return schemaPaths(fromJSONObject: object)
    }

    public static func schemaFingerprint(fromRawPayload rawPayload: String) -> String? {
        guard let object = jsonObject(fromRawPayload: rawPayload) else { return nil }
        return schemaFingerprint(fromJSONObject: object)
    }

    private static func shouldCapture(_ record: EulerDebugEventRecord) -> Bool {
        switch record.decodeOutcome {
        case .unknownEvent, .decodedWithPartialData:
            return true
        default:
            return false
        }
    }

    private func capture(record: EulerDebugEventRecord) throws {
        guard let object = Self.jsonObject(fromRawPayload: record.rawPayload) else { return }

        let safeEventName = Self.safePathComponent(record.eventName.isEmpty ? "unknown" : record.eventName)
        let schemaPaths = Self.schemaPaths(fromJSONObject: object)
        let fingerprint = Self.schemaFingerprint(fromJSONObject: object)
        let primaryMessageTypes = Self.primaryMessageTypes(fromJSONObject: object)
        let unknownDirectory = baseDirectoryURL
            .appendingPathComponent("unknown", isDirectory: true)
            .appendingPathComponent(safeEventName, isDirectory: true)

        try fileManager.createDirectory(at: unknownDirectory, withIntermediateDirectories: true)

        var manifest = try loadManifest(for: safeEventName)

        if let index = manifest.firstIndex(where: { $0.fingerprint == fingerprint }) {
            manifest[index].recordCount += 1
            manifest[index].lastSeenAt = record.receivedAt
            manifest[index].primaryMessageTypes = Array(Set(manifest[index].primaryMessageTypes + primaryMessageTypes)).sorted()
            try saveManifest(manifest, for: safeEventName)
            return
        }

        let fileName = "\(Self.timestampString(from: record.receivedAt))__\(Self.shortHash(of: record.rawPayload)).json"
        let payloadURL = unknownDirectory.appendingPathComponent(fileName)
        try record.rawPayload.write(to: payloadURL, atomically: true, encoding: .utf8)

        let entry = EulerUnknownPayloadManifestEntry(
            eventName: safeEventName,
            fingerprint: fingerprint,
            schemaPaths: schemaPaths,
            recordCount: 1,
            firstSeenAt: record.receivedAt,
            lastSeenAt: record.receivedAt,
            representativeFileName: fileName,
            primaryMessageTypes: primaryMessageTypes
        )

        manifest.append(entry)
        manifest.sort { lhs, rhs in
            if lhs.lastSeenAt == rhs.lastSeenAt {
                return lhs.fingerprint < rhs.fingerprint
            }
            return lhs.lastSeenAt > rhs.lastSeenAt
        }

        try saveManifest(manifest, for: safeEventName)
    }

    private func loadManifest(for safeEventName: String) throws -> [EulerUnknownPayloadManifestEntry] {
        let manifestURL = manifestURL(for: safeEventName)
        guard fileManager.fileExists(atPath: manifestURL.path) else { return [] }
        let data = try Data(contentsOf: manifestURL)
        return try decoder.decode([EulerUnknownPayloadManifestEntry].self, from: data)
    }

    private func saveManifest(_ manifest: [EulerUnknownPayloadManifestEntry], for safeEventName: String) throws {
        let manifestURL = manifestURL(for: safeEventName)
        try fileManager.createDirectory(at: manifestURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try encoder.encode(manifest)
        try data.write(to: manifestURL, options: .atomic)
    }

    private func manifestURL(for safeEventName: String) -> URL {
        baseDirectoryURL
            .appendingPathComponent("unknown", isDirectory: true)
            .appendingPathComponent(safeEventName, isDirectory: true)
            .appendingPathComponent("manifest.json")
    }

    private static func jsonObject(fromRawPayload rawPayload: String) -> [String: Any]? {
        guard let data = rawPayload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let object = json as? [String: Any] else {
            return nil
        }
        return object
    }

    private static func schemaFingerprint(fromJSONObject object: [String: Any]) -> String {
        let joined = schemaPaths(fromJSONObject: object).joined(separator: "\n")
        return shortHash(of: joined)
    }

    private static func schemaPaths(fromJSONObject object: [String: Any]) -> [String] {
        var paths = Set<String>()
        collectSchemaPaths(from: object, prefix: "", into: &paths)
        return Array(paths).sorted()
    }

    private static func collectSchemaPaths(from value: Any, prefix: String, into paths: inout Set<String>) {
        if let object = value as? [String: Any] {
            if object.isEmpty, !prefix.isEmpty {
                paths.insert(prefix)
            }
            for key in object.keys.sorted() {
                let childPrefix = prefix.isEmpty ? key : "\(prefix).\(key)"
                collectSchemaPaths(from: object[key] as Any, prefix: childPrefix, into: &paths)
            }
            return
        }

        if let array = value as? [Any] {
            let arrayPrefix = prefix.isEmpty ? "[]" : "\(prefix)[]"
            if array.isEmpty {
                paths.insert(arrayPrefix)
            } else {
                for item in array {
                    collectSchemaPaths(from: item, prefix: arrayPrefix, into: &paths)
                }
            }
            return
        }

        if !prefix.isEmpty {
            paths.insert(prefix)
        }
    }

    private static func primaryMessageTypes(fromJSONObject object: [String: Any]) -> [String] {
        guard let messages = object["messages"] as? [[String: Any]] else { return [] }
        let values = messages.compactMap { $0["type"] as? String }
        return Array(Set(values)).sorted()
    }

    private static func safePathComponent(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        let unicodeScalars = value.lowercased().unicodeScalars.map { scalar -> Character in
            allowed.contains(scalar) ? Character(scalar) : "_"
        }
        let raw = String(unicodeScalars)
        let collapsed = raw.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
        return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "_")).isEmpty ? "unknown" : collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }

    private static func shortHash(of value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined().prefix(16).description
    }

    private static func timestampString(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
            .replacingOccurrences(of: ":", with: "-")
    }
}
