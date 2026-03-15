
import Testing
@testable import EulerLiveKit

struct ConfigurationTests {

    @Test
    func tokenEndpointURLBuildsCorrectly() {

        let config = EulerLiveConfiguration(
            backendBaseURL: URL(string: "https://example.com/api")!,
            tokenEndpointPath: "/token"
        )

        #expect(config.tokenEndpointURL.absoluteString == "https://example.com/api/token")
    }

    @Test
    func historyLimitClampsToMinimum() {

        let config = EulerLiveConfiguration(
            backendBaseURL: URL(string: "https://example.com")!,
            eventHistoryLimit: 0
        )

        #expect(config.eventHistoryLimit == 1)
    }
}
