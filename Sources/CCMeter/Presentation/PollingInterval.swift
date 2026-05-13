import Foundation

enum PollingInterval: Int, CaseIterable, Sendable {
    case oneMinute = 60
    case threeMinutes = 180
    case fiveMinutes = 300
    case tenMinutes = 600
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    case sixtyMinutes = 3600

    var displayLabel: String {
        switch self {
        case .oneMinute: return "1 min"
        case .threeMinutes: return "3 min"
        case .fiveMinutes: return "5 min"
        case .tenMinutes: return "10 min"
        case .fifteenMinutes: return "15 min"
        case .thirtyMinutes: return "30 min"
        case .sixtyMinutes: return "60 min"
        }
    }

    var seconds: Int { rawValue }
}
