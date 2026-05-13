import Foundation

private extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+")
        return allowed
    }()
}

final class TokenRefreshDataSource: TokenRefreshDataSourceProtocol,
    Sendable
{
    private static let tokenURL = URL(
        string: "https://platform.claude.com/v1/oauth/token"
    )!
    private static let clientID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e"

    func refresh(
        refreshToken: String
    ) async throws -> TokenRefreshResponseDTO {
        var request = URLRequest(url: Self.tokenURL)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        request.timeoutInterval = 10

        let params: [(String, String)] = [
            ("grant_type", "refresh_token"),
            ("refresh_token", refreshToken),
            ("client_id", Self.clientID),
        ]
        let body = params.map { key, value in
            let encodedValue = value.addingPercentEncoding(
                withAllowedCharacters: .urlQueryValueAllowed
            ) ?? value
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DomainError.tokenRefreshFailed("Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            throw DomainError.tokenRefreshFailed(
                "HTTP \(httpResponse.statusCode)"
            )
        }

        return try JSONDecoder().decode(
            TokenRefreshResponseDTO.self,
            from: data
        )
    }
}
