import Foundation
import Testing
@testable import CCMeter

private final class MockTokenRepository: TokenRepositoryProtocol, @unchecked Sendable {
    var loadResults: [Result<OAuthCredentials, Error>] = [
        .success(TestFixtures.makeOAuthCredentials())
    ]
    var loadCallCount = 0

    func load() throws -> OAuthCredentials {
        let index = min(loadCallCount, loadResults.count - 1)
        loadCallCount += 1
        return try loadResults[index].get()
    }
}

private final class MockUsageRepository: UsageRepositoryProtocol, @unchecked Sendable {
    var result: Result<Usage, Error> = .success(TestFixtures.makeUsage())
    var receivedAccessToken: String?

    func fetch(accessToken: String) async throws -> Usage {
        receivedAccessToken = accessToken
        return try result.get()
    }
}

@Suite("UsageDomainService")
struct UsageDomainServiceTests {
    private let mockToken = MockTokenRepository()
    private let mockUsage = MockUsageRepository()
    private var sut: UsageDomainService {
        UsageDomainService(tokenRepository: mockToken, usageRepository: mockUsage)
    }

    @Test("valid token fetches usage immediately")
    func validToken_fetchesImmediately() async throws {
        mockToken.loadResults = [
            .success(TestFixtures.makeOAuthCredentials(
                accessToken: "valid-token",
                expiresAt: Date.now.addingTimeInterval(3600)
            ))
        ]

        _ = try await sut.fetchCurrentUsage()

        #expect(mockToken.loadCallCount == 1)
        #expect(mockUsage.receivedAccessToken == "valid-token")
    }

    @Test("token beyond 5-minute buffer does not retry")
    func tokenBeyondBuffer_noRetry() async throws {
        mockToken.loadResults = [
            .success(TestFixtures.makeOAuthCredentials(
                accessToken: "still-good",
                expiresAt: Date.now.addingTimeInterval(400)
            ))
        ]

        _ = try await sut.fetchCurrentUsage()

        #expect(mockToken.loadCallCount == 1)
        #expect(mockUsage.receivedAccessToken == "still-good")
    }

    @Test("expired token retries and succeeds when refreshed")
    func expiredToken_retriesAndSucceeds() async throws {
        mockToken.loadResults = [
            .success(TestFixtures.makeOAuthCredentials(
                expiresAt: Date.now.addingTimeInterval(-60)
            )),
            .success(TestFixtures.makeOAuthCredentials(
                accessToken: "refreshed-token",
                expiresAt: Date.now.addingTimeInterval(3600)
            )),
        ]

        _ = try await sut.fetchCurrentUsage()

        #expect(mockToken.loadCallCount == 2)
        #expect(mockUsage.receivedAccessToken == "refreshed-token")
    }

    @Test("expired token throws after all retries exhausted")
    func expiredToken_throwsAfterRetries() async {
        mockToken.loadResults = [
            .success(TestFixtures.makeOAuthCredentials(
                expiresAt: Date.now.addingTimeInterval(-60)
            ))
        ]

        await #expect(throws: DomainError.self) {
            _ = try await sut.fetchCurrentUsage()
        }
        #expect(mockToken.loadCallCount == 4)
    }

    @Test("load error propagates without retry")
    func loadError_propagates() async {
        mockToken.loadResults = [.failure(DomainError.tokenNotFound)]

        await #expect(throws: DomainError.self) {
            _ = try await sut.fetchCurrentUsage()
        }
        #expect(mockToken.loadCallCount == 1)
        #expect(mockUsage.receivedAccessToken == nil)
    }

    @Test("fetch error propagates")
    func fetchError_propagates() async {
        mockUsage.result = .failure(DomainError.apiRequestFailed(statusCode: 500))

        await #expect(throws: DomainError.self) {
            _ = try await sut.fetchCurrentUsage()
        }
    }
}
