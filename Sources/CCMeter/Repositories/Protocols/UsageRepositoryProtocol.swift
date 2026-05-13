protocol UsageRepositoryProtocol: Sendable {
    func fetch(accessToken: String) async throws -> Usage
}
