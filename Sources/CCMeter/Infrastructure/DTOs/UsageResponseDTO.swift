import Foundation

struct UsageResponseDTO: Codable, Sendable {
    let fiveHour: RateLimitDTO?
    let sevenDay: RateLimitDTO?
    let sevenDaySonnet: RateLimitDTO?
    let extraUsage: ExtraUsageDTO?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDaySonnet = "seven_day_sonnet"
        case extraUsage = "extra_usage"
    }
}

struct RateLimitDTO: Codable, Sendable {
    let utilization: Double?
    let resetsAt: String?

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

struct ExtraUsageDTO: Codable, Sendable {
    let isEnabled: Bool
    let monthlyLimit: Int?
    let usedCredits: Double?
    let utilization: Double?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case monthlyLimit = "monthly_limit"
        case usedCredits = "used_credits"
        case utilization
        case currency
    }
}
