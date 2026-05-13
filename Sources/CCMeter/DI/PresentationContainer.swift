final class PresentationContainer: Sendable {
    private let fetchUsage: FetchUsageUseCaseProtocol

    init(useCases: UseCaseContainer) {
        fetchUsage = useCases.fetchUsage
    }

    @MainActor
    func makeUsageViewModel() -> UsageViewModel {
        UsageViewModel(fetchUsage: fetchUsage)
    }
}
