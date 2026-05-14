import Foundation

enum DomainError: LocalizedError, Sendable {
    case tokenNotFound
    case tokenExpired
    case apiRequestFailed(statusCode: Int)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .tokenNotFound:
            return "Claude Code credentials not found in Keychain"
        case .tokenExpired:
            return "Token is expired. Please use Claude Code to refresh your session"
        case .apiRequestFailed(let statusCode):
            return "API request failed with status \(statusCode)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        }
    }
}
