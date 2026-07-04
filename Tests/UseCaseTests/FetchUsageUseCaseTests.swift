import Foundation
import Testing
@testable import CCMeter

private final class MockUsageDomainService: UsageDomainServiceProtocol, @unchecked Sendable {
    var result: Result<Usage, Error> = .success(TestFixtures.makeUsage())

    func fetchCurrentUsage() async throws -> Usage {
        try result.get()
    }
}

@Suite("FetchUsageUseCase")
struct FetchUsageUseCaseTests {
    private let mockService = MockUsageDomainService()
    private var sut: FetchUsageUseCase { FetchUsageUseCase(domainService: mockService) }

    @Test("execute maps Usage to FetchUsageResponse")
    func execute_mapsToResponse() async throws {
        let usage = Usage(
            fiveHour: RateLimit(utilization: 75.6, resetsAt: Date.now),
            sevenDay: RateLimit(utilization: 30.0, resetsAt: Date.now),
            sevenDayModel: nil,
            extraUsage: nil
        )
        mockService.result = .success(usage)

        let response = try await sut.execute(FetchUsageRequest())

        #expect(response.fiveHour?.utilization == 75)
        #expect(response.sevenDay?.utilization == 30)
        #expect(response.sevenDayModel == nil)
        #expect(response.extraUsage == nil)
    }

    @Test("execute maps dynamic model rate limit")
    func execute_mapsModelRateLimit() async throws {
        let resetsAt = Date.now
        mockService.result = .success(
            Usage(
                fiveHour: nil, sevenDay: nil,
                sevenDayModel: ModelRateLimit(
                    modelName: "Fable",
                    rateLimit: RateLimit(utilization: 1.0, resetsAt: resetsAt)
                ),
                extraUsage: nil
            )
        )

        let response = try await sut.execute(FetchUsageRequest())

        #expect(response.sevenDayModel?.modelName == "Fable")
        #expect(response.sevenDayModel?.utilization == 1)
    }

    @Test("execute with all nil Usage returns all nil response")
    func execute_allNil() async throws {
        mockService.result = .success(
            Usage(fiveHour: nil, sevenDay: nil, sevenDayModel: nil, extraUsage: nil)
        )

        let response = try await sut.execute(FetchUsageRequest())

        #expect(response.fiveHour == nil)
        #expect(response.sevenDay == nil)
        #expect(response.sevenDayModel == nil)
        #expect(response.extraUsage == nil)
    }

    @Test("execute maps extra usage fields")
    func execute_mapsExtraUsage() async throws {
        mockService.result = .success(
            Usage(
                fiveHour: nil, sevenDay: nil, sevenDayModel: nil,
                extraUsage: ExtraUsageInfo(
                    isEnabled: true, monthlyLimit: 100,
                    usedCredits: 42.5, utilization: 0.425, currency: "USD"
                )
            )
        )

        let response = try await sut.execute(FetchUsageRequest())
        let extra = try #require(response.extraUsage)

        #expect(extra.isEnabled == true)
        #expect(extra.monthlyLimit == 100)
        #expect(extra.usedCredits == 42.5)
        #expect(extra.currency == "USD")
    }

    @Test("execute propagates domain service error")
    func execute_propagatesError() async {
        mockService.result = .failure(DomainError.tokenNotFound)

        await #expect(throws: DomainError.self) {
            _ = try await sut.execute(FetchUsageRequest())
        }
    }
}
