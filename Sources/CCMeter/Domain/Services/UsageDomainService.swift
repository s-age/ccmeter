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
        let buffer: TimeInterval = 300
        let maxRetries = 3

        for attempt in 0...maxRetries {
            let credentials = try tokenRepository.load()
            if credentials.expiresAt >= Date.now.addingTimeInterval(buffer) {
                return try await usageRepository.fetch(
                    accessToken: credentials.accessToken
                )
            }
            if attempt < maxRetries {
                try await Task.sleep(for: .seconds(3))
            }
        }

        throw DomainError.tokenExpired
    }
}
