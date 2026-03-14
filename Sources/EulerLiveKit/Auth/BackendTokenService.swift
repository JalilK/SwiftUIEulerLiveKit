import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct BackendTokenService: EulerTokenProvider {
    private struct TokenRequestBody: Encodable {
        let uniqueId: String
        let creator: String
    }

    private struct TokenResponseBody: Decodable {
        let creator: String?
        let jwtKey: String
        let websocketURL: String
        let expiresInSeconds: Int?
        let strategy: String?
    }

    private let configuration: EulerLiveConfiguration
    private let session: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(configuration: EulerLiveConfiguration) {
        self.configuration = configuration
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = configuration.requestTimeoutSeconds
        sessionConfiguration.timeoutIntervalForResource = configuration.requestTimeoutSeconds
        self.session = URLSession(configuration: sessionConfiguration)
        self.jsonEncoder = JSONEncoder()
        self.jsonDecoder = JSONDecoder()
    }

    public func fetchCredentials(for uniqueId: String) async throws -> EulerWebSocketCredentials {
        var request = URLRequest(url: configuration.tokenEndpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(TokenRequestBody(uniqueId: uniqueId, creator: uniqueId))

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EulerLiveError.invalidBackendResponse
        }
        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw EulerLiveError.tokenRequestFailed(httpResponse.statusCode)
        }

        let payload = try jsonDecoder.decode(TokenResponseBody.self, from: data)
        guard let websocketURL = URL(string: payload.websocketURL) else {
            throw EulerLiveError.invalidWebSocketURL
        }

        return EulerWebSocketCredentials(
            creator: payload.creator,
            jwtKey: payload.jwtKey,
            websocketURL: websocketURL,
            expiresInSeconds: payload.expiresInSeconds,
            strategy: payload.strategy
        )
    }
}
