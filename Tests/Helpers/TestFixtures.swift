import Foundation
@testable import CCMeter

enum TestFixtures {
    static func makeOAuthCredentials(
        accessToken: String = "test-access-token",
        refreshToken: String = "test-refresh-token",
        expiresAt: Date = Date.now.addingTimeInterval(3600)
    ) -> OAuthCredentials {
        OAuthCredentials(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }

    static func makeUsage(
        fiveHour: RateLimit? = RateLimit(utilization: 25.0, resetsAt: Date.now.addingTimeInterval(3600)),
        sevenDay: RateLimit? = RateLimit(utilization: 50.0, resetsAt: Date.now.addingTimeInterval(86400)),
        sevenDaySonnet: RateLimit? = nil,
        extraUsage: ExtraUsageInfo? = nil
    ) -> Usage {
        Usage(
            fiveHour: fiveHour,
            sevenDay: sevenDay,
            sevenDaySonnet: sevenDaySonnet,
            extraUsage: extraUsage
        )
    }

    static func makeUsageResponseDTO(
        fiveHour: RateLimitDTO? = RateLimitDTO(utilization: 25.0, resetsAt: "2025-01-01T00:00:00.000Z"),
        sevenDay: RateLimitDTO? = RateLimitDTO(utilization: 50.0, resetsAt: "2025-01-02T00:00:00.000Z"),
        sevenDaySonnet: RateLimitDTO? = nil,
        extraUsage: ExtraUsageDTO? = nil
    ) -> UsageResponseDTO {
        UsageResponseDTO(
            fiveHour: fiveHour,
            sevenDay: sevenDay,
            sevenDaySonnet: sevenDaySonnet,
            extraUsage: extraUsage
        )
    }

    static func makeKeychainCredentialsDTO(
        accessToken: String = "test-access-token",
        refreshToken: String = "test-refresh-token",
        expiresAt: Int64 = 1700000000000,
        scopes: [String] = []
    ) -> KeychainCredentialsDTO {
        KeychainCredentialsDTO(
            claudeAiOauth: .init(
                accessToken: accessToken,
                refreshToken: refreshToken,
                expiresAt: expiresAt,
                scopes: scopes
            )
        )
    }

    static func makeTokenRefreshResponseDTO(
        accessToken: String = "new-access-token",
        refreshToken: String = "new-refresh-token",
        expiresIn: Int = 3600
    ) -> TokenRefreshResponseDTO {
        TokenRefreshResponseDTO(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
    }
}
