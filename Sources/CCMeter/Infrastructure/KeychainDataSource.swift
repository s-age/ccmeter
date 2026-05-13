import Foundation
import Security

final class KeychainDataSource: KeychainDataSourceProtocol, Sendable {
    private static let serviceName = "Claude Code-credentials"

    func read() throws -> KeychainCredentialsDTO {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.serviceName,
            kSecAttrAccount as String: NSUserName(),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            throw DomainError.tokenNotFound
        }

        return try JSONDecoder().decode(
            KeychainCredentialsDTO.self,
            from: data
        )
    }

    func write(_ credentials: KeychainCredentialsDTO) throws {
        let data = try JSONEncoder().encode(credentials)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.serviceName,
            kSecAttrAccount as String: NSUserName()
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw DomainError.tokenRefreshFailed(
                    "Keychain write failed: \(addStatus)"
                )
            }
        } else if status != errSecSuccess {
            throw DomainError.tokenRefreshFailed(
                "Keychain update failed: \(status)"
            )
        }
    }
}
