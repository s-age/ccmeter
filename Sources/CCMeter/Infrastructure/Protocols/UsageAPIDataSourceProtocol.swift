protocol UsageAPIDataSourceProtocol: Sendable {
    func fetch(accessToken: String) async throws -> UsageResponseDTO
}
