import Foundation
import Testing
@testable import EulerLiveKit

struct EulerConfigurationTests {
    @Test
    func tokenEndpointURLSupportsLeadingSlashPath() {
        let configuration = EulerLiveConfiguration(
            backendBaseURL: URL(string: "https://example.com/api")!,
            tokenEndpointPath: "/token"
        )

        #expect(configuration.tokenEndpointURL.absoluteString == "https://example.com/api/token")
    }

    @Test
    func tokenEndpointURLSupportsPathWithoutLeadingSlash() {
        let configuration = EulerLiveConfiguration(
            backendBaseURL: URL(string: "https://example.com/api")!,
            tokenEndpointPath: "token"
        )

        #expect(configuration.tokenEndpointURL.absoluteString == "https://example.com/api/token")
    }

    @Test
    func configurationClampsHistoryLimitAndTimeout() {
        let configuration = EulerLiveConfiguration(
            backendBaseURL: URL(string: "https://example.com")!,
            eventHistoryLimit: 0,
            requestTimeoutSeconds: 0
        )

        #expect(configuration.eventHistoryLimit == 1)
        #expect(configuration.requestTimeoutSeconds == 1)
    }
}
