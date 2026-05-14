import Foundation
import Testing
@testable import CCMeter

private final class MockKeychainDataSource: KeychainDataSourceProtocol, @unchecked Sendable {
    var readResult: Result<KeychainCredentialsDTO, Error> = .success(TestFixtures.makeKeychainCredentialsDTO())

    func read() throws -> KeychainCredentialsDTO {
        try readResult.get()
    }
}

@Suite("TokenRepository")
struct TokenRepositoryTests {
    private let mockKeychain = MockKeychainDataSource()
    private var sut: TokenRepository {
        TokenRepository(keychainDataSource: mockKeychain)
    }

    @Test("load converts DTO milliseconds to Date")
    func load_convertsMsToDate() throws {
        mockKeychain.readResult = .success(
            TestFixtures.makeKeychainCredentialsDTO(
                accessToken: "at", expiresAt: 1700000000000
            )
        )

        let creds = try sut.load()

        #expect(creds.accessToken == "at")
        #expect(creds.expiresAt == Date(timeIntervalSince1970: 1700000000))
    }

    @Test("load propagates keychain error")
    func load_propagatesError() {
        mockKeychain.readResult = .failure(DomainError.tokenNotFound)

        #expect(throws: DomainError.self) {
            _ = try sut.load()
        }
    }
}
