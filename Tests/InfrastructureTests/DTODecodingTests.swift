import Foundation
import Testing
@testable import CCMeter

@Suite("DTO Decoding")
struct DTODecodingTests {
    private let decoder = JSONDecoder()

    @Test("UsageResponseDTO decodes snake_case JSON with all fields")
    func usageResponseDTO_decodesFullJSON() throws {
        let json = """
        {
            "five_hour": {"utilization": 0.25, "resets_at": "2025-01-01T00:00:00.000Z"},
            "seven_day": {"utilization": 0.50, "resets_at": "2025-01-02T00:00:00.000Z"},
            "seven_day_sonnet": {"utilization": 0.10, "resets_at": "2025-01-03T00:00:00.000Z"},
            "extra_usage": {
                "is_enabled": true,
                "monthly_limit": 100,
                "used_credits": 42.5,
                "utilization": 0.425,
                "currency": "USD"
            }
        }
        """.data(using: .utf8)!

        let dto = try decoder.decode(UsageResponseDTO.self, from: json)

        #expect(dto.fiveHour?.utilization == 0.25)
        #expect(dto.fiveHour?.resetsAt == "2025-01-01T00:00:00.000Z")
        #expect(dto.sevenDay?.utilization == 0.50)
        #expect(dto.sevenDaySonnet?.utilization == 0.10)
        #expect(dto.extraUsage?.isEnabled == true)
        #expect(dto.extraUsage?.monthlyLimit == 100)
        #expect(dto.extraUsage?.usedCredits == 42.5)
        #expect(dto.extraUsage?.currency == "USD")
    }

    @Test("UsageResponseDTO decodes with all null optionals")
    func usageResponseDTO_allNulls() throws {
        let json = """
        {
            "five_hour": null,
            "seven_day": null,
            "seven_day_sonnet": null,
            "extra_usage": null
        }
        """.data(using: .utf8)!

        let dto = try decoder.decode(UsageResponseDTO.self, from: json)

        #expect(dto.fiveHour == nil)
        #expect(dto.sevenDay == nil)
        #expect(dto.sevenDaySonnet == nil)
        #expect(dto.extraUsage == nil)
    }

    @Test("UsageResponseDTO decodes empty JSON object")
    func usageResponseDTO_missingKeys() throws {
        let json = "{}".data(using: .utf8)!
        let dto = try decoder.decode(UsageResponseDTO.self, from: json)

        #expect(dto.fiveHour == nil)
        #expect(dto.sevenDay == nil)
    }

    @Test("RateLimitDTO decodes with null fields")
    func rateLimitDTO_nullFields() throws {
        let json = """
        {"utilization": null, "resets_at": null}
        """.data(using: .utf8)!

        let dto = try decoder.decode(RateLimitDTO.self, from: json)

        #expect(dto.utilization == nil)
        #expect(dto.resetsAt == nil)
    }

    @Test("ExtraUsageDTO decodes snake_case JSON")
    func extraUsageDTO_decodes() throws {
        let json = """
        {
            "is_enabled": false,
            "monthly_limit": 200,
            "used_credits": 10.0,
            "utilization": 0.05,
            "currency": "EUR"
        }
        """.data(using: .utf8)!

        let dto = try decoder.decode(ExtraUsageDTO.self, from: json)

        #expect(dto.isEnabled == false)
        #expect(dto.monthlyLimit == 200)
        #expect(dto.usedCredits == 10.0)
        #expect(dto.currency == "EUR")
    }

    @Test("KeychainCredentialsDTO decodes nested structure")
    func keychainCredentialsDTO_decodesNested() throws {
        let json = """
        {
            "claudeAiOauth": {
                "accessToken": "tok",
                "refreshToken": "ref",
                "expiresAt": 1700000000000,
                "scopes": ["read", "write"]
            }
        }
        """.data(using: .utf8)!

        let dto = try decoder.decode(KeychainCredentialsDTO.self, from: json)

        #expect(dto.claudeAiOauth.accessToken == "tok")
        #expect(dto.claudeAiOauth.refreshToken == "ref")
        #expect(dto.claudeAiOauth.expiresAt == 1700000000000)
        #expect(dto.claudeAiOauth.scopes == ["read", "write"])
    }
}
