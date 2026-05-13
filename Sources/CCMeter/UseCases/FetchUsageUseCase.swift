final class FetchUsageUseCase: AsyncUseCase, Sendable {
    private let domainService: any UsageDomainServiceProtocol

    init(domainService: any UsageDomainServiceProtocol) {
        self.domainService = domainService
    }

    func execute(
        _ request: FetchUsageRequest
    ) async throws -> FetchUsageResponse {
        let usage = try await domainService.fetchCurrentUsage()
        return FetchUsageResponse(from: usage)
    }
}
