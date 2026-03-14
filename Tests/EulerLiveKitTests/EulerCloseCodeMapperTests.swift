import Testing
@testable import EulerLiveKit

struct EulerCloseCodeMapperTests {
    @Test
    func mapsKnownCodes() {
        #expect(EulerCloseCodeMapper.map(4404) == .notLive)
        #expect(EulerCloseCodeMapper.map(4401) == .invalidAuth)
        #expect(EulerCloseCodeMapper.map(1000) == .normalClosure)
    }

    @Test
    func keepsUnknownCodes() {
        #expect(EulerCloseCodeMapper.map(4999) == .serverCode(4999))
    }
}
