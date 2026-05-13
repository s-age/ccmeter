import SwiftUI

struct UsageRowView: View {
    let title: String
    let info: FetchUsageResponse.RateLimitInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text("\(info.utilization)%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(utilizationColor)
            }
            ProgressBarView(value: info.utilization)
            Text("Resets \(info.formattedResetTime)")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }

    private var utilizationColor: Color {
        if info.utilization < 50 { return .green }
        if info.utilization < 75 { return .orange }
        return .red
    }
}
