import Foundation
import Testing
@testable import CCMeter

private final class MockTokenRepository: TokenRepositoryProtocol, @unchecked Sendable {
    var loadResult: Result<OAuthCredentials, Error> = .success(TestFixtures.makeOAuthCredentials())
    var refreshResult: Result<OAuthCredentials, Error> = .success(
        TestFixtures.makeOAuthCredentials(accessToken: "refreshed-token")
    )
    var refreshCallCount = 0
    var receivedCredentials: OAuthCredentials?

    func load() throws -> OAuthCredentials {
        try loadResult.get()
    }

    func refresh(_ credentials: OAuthCredentials) async throws -> OAuthCredentials {
        refreshCallCount += 1
        receivedCredentials = credentials
        return try refreshResult.get()
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

    @Test("token not expired fetches usage with existing token")
    func tokenNotExpired_usesExistingToken() async throws {
        let creds = TestFixtures.makeOAuthCredentials(
            accessToken: "valid-token",
            expiresAt: Date.now.addingTimeInterval(3600)
        )
        mockToken.loadResult = .success(creds)

        _ = try await sut.fetchCurrentUsage()

        #expect(mockToken.refreshCallCount == 0)
        #expect(mockUsage.receivedAccessToken == "valid-token")
    }

    @Test("expired token triggers refresh before fetch")
    func tokenExpired_refreshesFirst() async throws {
        mockToken.loadResult = .success(
            TestFixtures.makeOAuthCredentials(expiresAt: Date.now.addingTimeInterval(-60))
        )
        mockToken.refreshResult = .success(
            TestFixtures.makeOAuthCredentials(accessToken: "refreshed-token")
        )

        _ = try await sut.fetchCurrentUsage()

        #expect(mockToken.refreshCallCount == 1)
        #expect(mockUsage.receivedAccessToken == "refreshed-token")
    }

    @Test("token expiring within 5-minute buffer triggers refresh")
    func tokenExpiringWithinBuffer_refreshes() async throws {
        mockToken.loadResult = .success(
            TestFixtures.makeOAuthCredentials(expiresAt: Date.now.addingTimeInterval(200))
        )
        mockToken.refreshResult = .success(
            TestFixtures.makeOAuthCredentials(accessToken: "new-token")
        )

        _ = try await sut.fetchCurrentUsage()

        #expect(mockToken.refreshCallCount == 1)
        #expect(mockUsage.receivedAccessToken == "new-token")
    }

    @Test("token expiring beyond buffer does not trigger refresh")
    func tokenBeyondBuffer_noRefresh() async throws {
        mockToken.loadResult = .success(
            TestFixtures.makeOAuthCredentials(
                accessToken: "still-good",
                expiresAt: Date.now.addingTimeInterval(400)
            )
        )

        _ = try await sut.fetchCurrentUsage()

        #expect(mockToken.refreshCallCount == 0)
        #expect(mockUsage.receivedAccessToken == "still-good")
    }

    @Test("load error propagates without calling refresh or fetch")
    func loadError_propagates() async {
        mockToken.loadResult = .failure(DomainError.tokenNotFound)

        await #expect(throws: DomainError.self) {
            _ = try await sut.fetchCurrentUsage()
        }
        #expect(mockToken.refreshCallCount == 0)
        #expect(mockUsage.receivedAccessToken == nil)
    }

    @Test("refresh error propagates without calling fetch")
    func refreshError_propagates() async {
        mockToken.loadResult = .success(
            TestFixtures.makeOAuthCredentials(expiresAt: Date.now.addingTimeInterval(-60))
        )
        mockToken.refreshResult = .failure(DomainError.tokenRefreshFailed("timeout"))

        await #expect(throws: DomainError.self) {
            _ = try await sut.fetchCurrentUsage()
        }
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
