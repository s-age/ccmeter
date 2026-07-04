import Foundation

struct Usage: Equatable, Sendable {
    let fiveHour: RateLimit?
    let sevenDay: RateLimit?
    let sevenDayModel: ModelRateLimit?
    let extraUsage: ExtraUsageInfo?
}

struct RateLimit: Equatable, Sendable {
    let utilization: Double
    let resetsAt: Date
}

struct ModelRateLimit: Equatable, Sendable {
    let modelName: String
    let rateLimit: RateLimit
}

struct ExtraUsageInfo: Equatable, Sendable {
    let isEnabled: Bool
    let monthlyLimit: Int?
    let usedCredits: Double?
    let utilization: Double?
    let currency: String?
}
