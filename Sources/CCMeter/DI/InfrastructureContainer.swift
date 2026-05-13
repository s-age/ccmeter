final class InfrastructureContainer: Sendable {
    let keychainDataSource: any KeychainDataSourceProtocol
    let usageAPIDataSource: any UsageAPIDataSourceProtocol
    let tokenRefreshDataSource: any TokenRefreshDataSourceProtocol

    init() {
        keychainDataSource = KeychainDataSource()
        usageAPIDataSource = UsageAPIDataSource()
        tokenRefreshDataSource = TokenRefreshDataSource()
    }
}
