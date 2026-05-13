import Foundation

enum DomainError: LocalizedError, Sendable {
    case tokenNotFound
    case tokenRefreshFailed(String)
    case apiRequestFailed(statusCode: Int)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .tokenNotFound:
            return "Claude Code credentials not found in Keychain"
        case .tokenRefreshFailed(let reason):
            return "Token refresh failed: \(reason)"
        case .apiRequestFailed(let statusCode):
            return "API request failed with status \(statusCode)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        }
    }
}
