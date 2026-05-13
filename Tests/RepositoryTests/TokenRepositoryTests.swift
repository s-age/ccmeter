import Foundation
import Testing
@testable import CCMeter

private final class MockKeychainDataSource: KeychainDataSourceProtocol, @unchecked Sendable {
    var readResult: Result<KeychainCredentialsDTO, Error> = .success(TestFixtures.makeKeychainCredentialsDTO())
    var writtenDTO: KeychainCredentialsDTO?
    var writeError: Error?

    func read() throws -> KeychainCredentialsDTO {
        try readResult.get()
    }

    func write(_ credentials: KeychainCredentialsDTO) throws {
        if let writeError { throw writeError }
        writtenDTO = credentials
    }
}

private final class MockTokenRefreshDataSource: TokenRefreshDataSourceProtocol, @unchecked Sendable {
    var result: Result<TokenRefreshResponseDTO, Error> = .success(TestFixtures.makeTokenRefreshResponseDTO())
    var receivedRefreshToken: String?

    func refresh(refreshToken: String) async throws -> TokenRefreshResponseDTO {
        receivedRefreshToken = refreshToken
        return try result.get()
    }
}

@Suite("TokenRepository")
struct TokenRepositoryTests {
    private let mockKeychain = MockKeychainDataSource()
    private let mockRefresh = MockTokenRefreshDataSource()
    private var sut: TokenRepository {
        TokenRepository(keychainDataSource: mockKeychain, tokenRefreshDataSource: mockRefresh)
    }

    // MARK: - load

    @Test("load converts DTO milliseconds to Date")
    func load_convertsMsToDate() throws {
        mockKeychain.readResult = .success(
            TestFixtures.makeKeychainCredentialsDTO(
                accessToken: "at", refreshToken: "rt", expiresAt: 1700000000000
            )
        )

        let creds = try sut.load()

        #expect(creds.accessToken == "at")
        #expect(creds.refreshToken == "rt")
        #expect(creds.expiresAt == Date(timeIntervalSince1970: 1700000000))
    }

    @Test("load propagates keychain error")
    func load_propagatesError() {
        mockKeychain.readResult = .failure(DomainError.tokenNotFound)

        #expect(throws: DomainError.self) {
            _ = try sut.load()
        }
    }

    // MARK: - refresh

    @Test("refresh returns new credentials with correct expiry")
    func refresh_returnsNewCredentials() async throws {
        mockRefresh.result = .success(
            TokenRefreshResponseDTO(accessToken: "new-at", refreshToken: "new-rt", expiresIn: 3600)
        )
        let before = Date.now
        let old = TestFixtures.makeOAuthCredentials()

        let result = try await sut.refresh(old)

        #expect(result.accessToken == "new-at")
        #expect(result.refreshToken == "new-rt")
        #expect(result.expiresAt.timeIntervalSince(before) >= 3598)
        #expect(result.expiresAt.timeIntervalSince(before) <= 3602)
    }

    @Test("refresh writes updated credentials to keychain")
    func refresh_writesToKeychain() async throws {
        mockRefresh.result = .success(
            TokenRefreshResponseDTO(accessToken: "new-at", refreshToken: "new-rt", expiresIn: 3600)
        )

        _ = try await sut.refresh(TestFixtures.makeOAuthCredentials())

        let written = try #require(mockKeychain.writtenDTO)
        #expect(written.claudeAiOauth.accessToken == "new-at")
        #expect(written.claudeAiOauth.refreshToken == "new-rt")
        #expect(written.claudeAiOauth.scopes == [])
    }

    @Test("refresh passes old refresh token to data source")
    func refresh_passesRefreshToken() async throws {
        let old = TestFixtures.makeOAuthCredentials(refreshToken: "old-rt")

        _ = try await sut.refresh(old)

        #expect(mockRefresh.receivedRefreshToken == "old-rt")
    }

    @Test("refresh propagates data source error")
    func refresh_dataSourceError_propagates() async {
        mockRefresh.result = .failure(DomainError.tokenRefreshFailed("timeout"))

        await #expect(throws: DomainError.self) {
            _ = try await sut.refresh(TestFixtures.makeOAuthCredentials())
        }
    }

    @Test("refresh propagates keychain write error")
    func refresh_writeError_propagates() async {
        mockKeychain.writeError = DomainError.tokenRefreshFailed("write failed")

        await #expect(throws: DomainError.self) {
            _ = try await sut.refresh(TestFixtures.makeOAuthCredentials())
        }
    }
}
