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
            sevenDayModel: Self.toModelRateLimit(dto),
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

    // Which model's weekly quota applies depends on what the account is currently using
    // (Sonnet, Fable, ...), so it's read from the generic `limits` array rather than a
    // fixed per-model field. Falls back to the legacy `seven_day_sonnet` field for API
    // responses that don't include `limits` yet.
    private static func toModelRateLimit(_ dto: UsageResponseDTO) -> ModelRateLimit? {
        if let scoped = dto.limits?.first(where: { $0.kind == "weekly_scoped" }),
           let modelName = scoped.scope?.model?.displayName,
           let percent = scoped.percent,
           let resetsAtString = scoped.resetsAt,
           let resetsAt = parseISO8601(resetsAtString)
        {
            return ModelRateLimit(
                modelName: modelName,
                rateLimit: RateLimit(utilization: Double(percent), resetsAt: resetsAt)
            )
        }

        if let legacy = dto.sevenDaySonnet.flatMap(Self.toRateLimit) {
            return ModelRateLimit(modelName: "Sonnet", rateLimit: legacy)
        }

        return nil
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
