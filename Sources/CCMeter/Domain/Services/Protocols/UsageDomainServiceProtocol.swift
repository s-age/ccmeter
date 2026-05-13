protocol UsageDomainServiceProtocol: Sendable {
    func fetchCurrentUsage() async throws -> Usage
}
