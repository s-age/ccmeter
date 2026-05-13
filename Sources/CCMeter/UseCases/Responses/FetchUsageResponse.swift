import Foundation

struct FetchUsageResponse: Equatable, Sendable {
    let fiveHour: RateLimitInfo?
    let sevenDay: RateLimitInfo?
    let sevenDaySonnet: RateLimitInfo?
    let extraUsage: ExtraUsageInfoResponse?

    struct RateLimitInfo: Equatable, Sendable {
        let utilization: Int
        let resetsAt: Date
    }

    struct ExtraUsageInfoResponse: Equatable, Sendable {
        let isEnabled: Bool
        let monthlyLimit: Int?
        let usedCredits: Double?
        let utilization: Double?
        let currency: String?
    }

    init(from usage: Usage) {
        self.fiveHour = usage.fiveHour.map(Self.toInfo)
        self.sevenDay = usage.sevenDay.map(Self.toInfo)
        self.sevenDaySonnet = usage.sevenDaySonnet.map(Self.toInfo)
        self.extraUsage = usage.extraUsage.map { extra in
            ExtraUsageInfoResponse(
                isEnabled: extra.isEnabled,
                monthlyLimit: extra.monthlyLimit,
                usedCredits: extra.usedCredits,
                utilization: extra.utilization,
                currency: extra.currency
            )
        }
    }

    private static func toInfo(_ limit: RateLimit) -> RateLimitInfo {
        RateLimitInfo(
            utilization: Int(limit.utilization),
            resetsAt: limit.resetsAt
        )
    }
}
