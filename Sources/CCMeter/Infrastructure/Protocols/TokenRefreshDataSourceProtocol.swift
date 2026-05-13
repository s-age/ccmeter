protocol TokenRefreshDataSourceProtocol: Sendable {
    func refresh(refreshToken: String) async throws -> TokenRefreshResponseDTO
}
