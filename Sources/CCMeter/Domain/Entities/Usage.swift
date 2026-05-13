import Foundation

struct Usage: Equatable, Sendable {
    let fiveHour: RateLimit?
    let sevenDay: RateLimit?
    let sevenDaySonnet: RateLimit?
    let extraUsage: ExtraUsageInfo?
}

struct RateLimit: Equatable, Sendable {
    let utilization: Double
    let resetsAt: Date
}

struct ExtraUsageInfo: Equatable, Sendable {
    let isEnabled: Bool
    let monthlyLimit: Int?
    let usedCredits: Double?
    let utilization: Double?
    let currency: String?
}
