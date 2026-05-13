final class UseCaseContainer: Sendable {
    let fetchUsage: FetchUsageUseCaseProtocol

    init(domain: DomainContainer) {
        fetchUsage = ValidationAsyncUseCaseDecorator(
            decoratee: FetchUsageUseCase(
                domainService: domain.usageService
            )
        )
    }
}
