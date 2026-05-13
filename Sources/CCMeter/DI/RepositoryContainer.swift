final class RepositoryContainer: Sendable {
    let tokenRepository: any TokenRepositoryProtocol
    let usageRepository: any UsageRepositoryProtocol

    init(infrastructure: InfrastructureContainer) {
        tokenRepository = TokenRepository(
            keychainDataSource: infrastructure.keychainDataSource,
            tokenRefreshDataSource: infrastructure.tokenRefreshDataSource
        )
        usageRepository = UsageRepository(
            apiDataSource: infrastructure.usageAPIDataSource
        )
    }
}
