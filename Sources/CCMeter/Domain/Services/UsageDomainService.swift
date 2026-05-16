import Foundation

final class UsageDomainService: UsageDomainServiceProtocol, Sendable {
    private let tokenRepository: any TokenRepositoryProtocol
    private let usageRepository: any UsageRepositoryProtocol

    init(
        tokenRepository: any TokenRepositoryProtocol,
        usageRepository: any UsageRepositoryProtocol
    ) {
        self.tokenRepository = tokenRepository
        self.usageRepository = usageRepository
    }

    func fetchCurrentUsage() async throws -> Usage {
        let credentials = try tokenRepository.load()
        guard credentials.expiresAt >= Date.now.addingTimeInterval(300) else {
            throw DomainError.tokenExpired
        }
        return try await usageRepository.fetch(accessToken: credentials.accessToken)
    }
}
