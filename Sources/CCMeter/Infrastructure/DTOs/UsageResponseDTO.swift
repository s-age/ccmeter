import Foundation

struct UsageResponseDTO: Codable, Sendable {
    let fiveHour: RateLimitDTO?
    let sevenDay: RateLimitDTO?
    let sevenDaySonnet: RateLimitDTO?
    let extraUsage: ExtraUsageDTO?
    let limits: [LimitDTO]?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDaySonnet = "seven_day_sonnet"
        case extraUsage = "extra_usage"
        case limits
    }

    init(
        fiveHour: RateLimitDTO? = nil,
        sevenDay: RateLimitDTO? = nil,
        sevenDaySonnet: RateLimitDTO? = nil,
        extraUsage: ExtraUsageDTO? = nil,
        limits: [LimitDTO]? = nil
    ) {
        self.fiveHour = fiveHour
        self.sevenDay = sevenDay
        self.sevenDaySonnet = sevenDaySonnet
        self.extraUsage = extraUsage
        self.limits = limits
    }
}

// The API also reports weekly limits generically per model (e.g. Sonnet, Fable) via
// `limits`, since which model's quota is relevant depends on what the account is using.
struct LimitDTO: Codable, Sendable {
    let kind: String
    let percent: Int?
    let resetsAt: String?
    let scope: LimitScopeDTO?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case kind
        case percent
        case resetsAt = "resets_at"
        case scope
        case isActive = "is_active"
    }
}

struct LimitScopeDTO: Codable, Sendable {
    let model: LimitModelScopeDTO?
}

struct LimitModelScopeDTO: Codable, Sendable {
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
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
