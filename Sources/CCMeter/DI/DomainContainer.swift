final class DomainContainer: Sendable {
    let usageService: any UsageDomainServiceProtocol

    init(repositories: RepositoryContainer) {
        usageService = UsageDomainService(
            tokenRepository: repositories.tokenRepository,
            usageRepository: repositories.usageRepository
        )
    }
}
