final class InfrastructureContainer: Sendable {
    let keychainDataSource: any KeychainDataSourceProtocol
    let usageAPIDataSource: any UsageAPIDataSourceProtocol

    init() {
        keychainDataSource = KeychainDataSource()
        usageAPIDataSource = UsageAPIDataSource()
    }
}
