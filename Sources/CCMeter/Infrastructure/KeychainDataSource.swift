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

}
