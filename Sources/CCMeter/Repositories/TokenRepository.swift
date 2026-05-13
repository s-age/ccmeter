import Foundation

final class TokenRepository: TokenRepositoryProtocol, Sendable {
    private let keychainDataSource: any KeychainDataSourceProtocol
    private let tokenRefreshDataSource: any TokenRefreshDataSourceProtocol

    init(
        keychainDataSource: any KeychainDataSourceProtocol,
        tokenRefreshDataSource: any TokenRefreshDataSourceProtocol
    ) {
        self.keychainDataSource = keychainDataSource
        self.tokenRefreshDataSource = tokenRefreshDataSource
    }

    func load() throws -> OAuthCredentials {
        let dto = try keychainDataSource.read()
        return OAuthCredentials(
            accessToken: dto.claudeAiOauth.accessToken,
            refreshToken: dto.claudeAiOauth.refreshToken,
            expiresAt: Date(
                timeIntervalSince1970: Double(dto.claudeAiOauth.expiresAt) / 1000
            )
        )
    }

    func refresh(
        _ credentials: OAuthCredentials
    ) async throws -> OAuthCredentials {
        let response = try await tokenRefreshDataSource.refresh(
            refreshToken: credentials.refreshToken
        )

        let newCredentials = OAuthCredentials(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: Date.now.addingTimeInterval(
                Double(response.expiresIn)
            )
        )

        let dto = KeychainCredentialsDTO(
            claudeAiOauth: .init(
                accessToken: newCredentials.accessToken,
                refreshToken: newCredentials.refreshToken,
                expiresAt: Int64(
                    newCredentials.expiresAt.timeIntervalSince1970 * 1000
                ),
                scopes: []
            )
        )
        try keychainDataSource.write(dto)

        return newCredentials
    }
}
