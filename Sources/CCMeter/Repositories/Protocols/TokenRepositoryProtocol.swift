protocol TokenRepositoryProtocol: Sendable {
    func load() throws -> OAuthCredentials
}
