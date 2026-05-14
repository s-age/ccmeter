protocol KeychainDataSourceProtocol: Sendable {
    func read() throws -> KeychainCredentialsDTO
}
