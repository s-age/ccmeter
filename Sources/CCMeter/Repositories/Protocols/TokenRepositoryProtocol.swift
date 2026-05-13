protocol TokenRepositoryProtocol: Sendable {
    func load() throws -> OAuthCredentials
    func refresh(_ credentials: OAuthCredentials) async throws -> OAuthCredentials
}
