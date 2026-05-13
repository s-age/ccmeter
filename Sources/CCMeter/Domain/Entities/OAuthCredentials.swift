import Foundation

struct OAuthCredentials: Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}
