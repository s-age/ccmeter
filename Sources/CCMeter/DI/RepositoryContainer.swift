final class RepositoryContainer: Sendable {
    let tokenRepository: any TokenRepositoryProtocol
    let usageRepository: any UsageRepositoryProtocol

    init(infrastructure: InfrastructureContainer) {
        tokenRepository = TokenRepository(
            keychainDataSource: infrastructure.keychainDataSource
        )
        usageRepository = UsageRepository(
            apiDataSource: infrastructure.usageAPIDataSource
        )
    }
}
