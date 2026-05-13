import Foundation

final class UsageRepository: UsageRepositoryProtocol, Sendable {
    private let apiDataSource: any UsageAPIDataSourceProtocol

    init(apiDataSource: any UsageAPIDataSourceProtocol) {
        self.apiDataSource = apiDataSource
    }

    func fetch(accessToken: String) async throws -> Usage {
        let dto = try await apiDataSource.fetch(accessToken: accessToken)
        return Usage(
            fiveHour: dto.fiveHour.flatMap(Self.toRateLimit),
            sevenDay: dto.sevenDay.flatMap(Self.toRateLimit),
            sevenDaySonnet: dto.sevenDaySonnet.flatMap(Self.toRateLimit),
            extraUsage: dto.extraUsage.map(Self.toExtraUsage)
        )
    }

    private static func toRateLimit(_ dto: RateLimitDTO) -> RateLimit? {
        guard let utilization = dto.utilization,
              let resetsAtString = dto.resetsAt,
              let resetsAt = parseISO8601(resetsAtString)
        else { return nil }
        return RateLimit(utilization: utilization, resetsAt: resetsAt)
    }

    private static func toExtraUsage(_ dto: ExtraUsageDTO) -> ExtraUsageInfo {
        ExtraUsageInfo(
            isEnabled: dto.isEnabled,
            monthlyLimit: dto.monthlyLimit,
            usedCredits: dto.usedCredits,
            utilization: dto.utilization,
            currency: dto.currency
        )
    }

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()

    private static func parseISO8601(_ string: String) -> Date? {
        iso8601Formatter.date(from: string)
    }
}
