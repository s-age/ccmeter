import Foundation

struct KeychainCredentialsDTO: Codable, Sendable {
    let claudeAiOauth: OAuthTokenDTO

    struct OAuthTokenDTO: Codable, Sendable {
        let accessToken: String
        let refreshToken: String
        let expiresAt: Int64
        let scopes: [String]
    }
}
