import Foundation

struct OAuthCredentials: Equatable, Sendable {
    let accessToken: String
    let expiresAt: Date
}
