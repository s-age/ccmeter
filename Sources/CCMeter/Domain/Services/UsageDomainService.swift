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
        var credentials = try tokenRepository.load()
        let buffer: TimeInterval = 300
        if credentials.expiresAt < Date.now.addingTimeInterval(buffer) {
            credentials = try await tokenRepository.refresh(credentials)
        }
        return try await usageRepository.fetch(
            accessToken: credentials.accessToken
        )
    }
}
