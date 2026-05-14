import Foundation

final class TokenRepository: TokenRepositoryProtocol, Sendable {
    private let keychainDataSource: any KeychainDataSourceProtocol

    init(keychainDataSource: any KeychainDataSourceProtocol) {
        self.keychainDataSource = keychainDataSource
    }

    func load() throws -> OAuthCredentials {
        let dto = try keychainDataSource.read()
        return OAuthCredentials(
            accessToken: dto.claudeAiOauth.accessToken,
            expiresAt: Date(
                timeIntervalSince1970: Double(dto.claudeAiOauth.expiresAt) / 1000
            )
        )
    }
}
