import Foundation

final class UsageAPIDataSource: UsageAPIDataSourceProtocol, Sendable {
    private static let usageURL = URL(
        string: "https://api.anthropic.com/api/oauth/usage"
    )!

    func fetch(accessToken: String) async throws -> UsageResponseDTO {
        var request = URLRequest(url: Self.usageURL)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(
            "oauth-2025-04-20",
            forHTTPHeaderField: "anthropic-beta"
        )
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DomainError.networkError("Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            throw DomainError.apiRequestFailed(
                statusCode: httpResponse.statusCode
            )
        }

        return try JSONDecoder().decode(
            UsageResponseDTO.self,
            from: data
        )
    }
}
