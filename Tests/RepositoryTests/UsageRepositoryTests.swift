import Foundation
import Testing
@testable import CCMeter

private final class MockUsageAPIDataSource: UsageAPIDataSourceProtocol, @unchecked Sendable {
    var result: Result<UsageResponseDTO, Error> = .success(TestFixtures.makeUsageResponseDTO())
    var receivedAccessToken: String?

    func fetch(accessToken: String) async throws -> UsageResponseDTO {
        receivedAccessToken = accessToken
        return try result.get()
    }
}

@Suite("UsageRepository")
struct UsageRepositoryTests {
    private let mockDataSource = MockUsageAPIDataSource()
    private var sut: UsageRepository { UsageRepository(apiDataSource: mockDataSource) }

    @Test("fetch maps all DTO fields to domain entity")
    func fetch_fullDTO_mapsAllFields() async throws {
        let dto = UsageResponseDTO(
            fiveHour: RateLimitDTO(utilization: 25.0, resetsAt: "2025-01-01T00:00:00.000Z"),
            sevenDay: RateLimitDTO(utilization: 50.0, resetsAt: "2025-06-15T12:30:00.000Z"),
            sevenDaySonnet: RateLimitDTO(utilization: 10.0, resetsAt: "2025-01-03T00:00:00.000Z"),
            extraUsage: ExtraUsageDTO(
                isEnabled: true, monthlyLimit: 100,
                usedCredits: 42.5, utilization: 0.425, currency: "USD"
            )
        )
        mockDataSource.result = .success(dto)

        let usage = try await sut.fetch(accessToken: "token")

        #expect(usage.fiveHour?.utilization == 25.0)
        #expect(usage.sevenDay?.utilization == 50.0)
        #expect(usage.sevenDaySonnet?.utilization == 10.0)
        #expect(usage.extraUsage?.isEnabled == true)
        #expect(usage.extraUsage?.monthlyLimit == 100)
        #expect(usage.extraUsage?.usedCredits == 42.5)
        #expect(usage.extraUsage?.currency == "USD")
    }

    @Test("fetch with all nil DTO fields returns Usage with all nils")
    func fetch_allNil() async throws {
        mockDataSource.result = .success(
            UsageResponseDTO(fiveHour: nil, sevenDay: nil, sevenDaySonnet: nil, extraUsage: nil)
        )

        let usage = try await sut.fetch(accessToken: "token")

        #expect(usage.fiveHour == nil)
        #expect(usage.sevenDay == nil)
        #expect(usage.sevenDaySonnet == nil)
        #expect(usage.extraUsage == nil)
    }

    @Test("fetch with nil utilization in RateLimitDTO maps to nil RateLimit")
    func fetch_nilUtilization_mapsToNil() async throws {
        mockDataSource.result = .success(
            UsageResponseDTO(
                fiveHour: RateLimitDTO(utilization: nil, resetsAt: "2025-01-01T00:00:00.000Z"),
                sevenDay: nil, sevenDaySonnet: nil, extraUsage: nil
            )
        )

        let usage = try await sut.fetch(accessToken: "token")

        #expect(usage.fiveHour == nil)
    }

    @Test("fetch with nil resetsAt in RateLimitDTO maps to nil RateLimit")
    func fetch_nilResetsAt_mapsToNil() async throws {
        mockDataSource.result = .success(
            UsageResponseDTO(
                fiveHour: RateLimitDTO(utilization: 25.0, resetsAt: nil),
                sevenDay: nil, sevenDaySonnet: nil, extraUsage: nil
            )
        )

        let usage = try await sut.fetch(accessToken: "token")

        #expect(usage.fiveHour == nil)
    }

    @Test("fetch with invalid date string maps to nil RateLimit")
    func fetch_invalidDate_mapsToNil() async throws {
        mockDataSource.result = .success(
            UsageResponseDTO(
                fiveHour: RateLimitDTO(utilization: 25.0, resetsAt: "not-a-date"),
                sevenDay: nil, sevenDaySonnet: nil, extraUsage: nil
            )
        )

        let usage = try await sut.fetch(accessToken: "token")

        #expect(usage.fiveHour == nil)
    }

    @Test("fetch passes access token to data source")
    func fetch_passesAccessToken() async throws {
        _ = try await sut.fetch(accessToken: "my-secret-token")

        #expect(mockDataSource.receivedAccessToken == "my-secret-token")
    }

    @Test("fetch propagates data source error")
    func fetch_propagatesError() async {
        mockDataSource.result = .failure(DomainError.apiRequestFailed(statusCode: 500))

        await #expect(throws: DomainError.self) {
            _ = try await sut.fetch(accessToken: "token")
        }
    }
}
