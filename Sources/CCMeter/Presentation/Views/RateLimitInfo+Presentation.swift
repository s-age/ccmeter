import Foundation

extension FetchUsageResponse.RateLimitInfo {
    var formattedResetTime: String {
        let now = Date.now
        let interval = resetsAt.timeIntervalSince(now)

        guard interval > 0 else { return "Reset" }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours >= 24 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d h:mma"
            let result = formatter.string(from: resetsAt)
            return result
                .replacingOccurrences(of: "AM", with: "am")
                .replacingOccurrences(of: "PM", with: "pm")
        }

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
