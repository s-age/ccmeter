protocol KeychainDataSourceProtocol: Sendable {
    func read() throws -> KeychainCredentialsDTO
    func write(_ credentials: KeychainCredentialsDTO) throws
}
