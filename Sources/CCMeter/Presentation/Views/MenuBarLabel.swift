import SwiftUI

struct MenuBarLabel: View {
    let viewModel: UsageViewModel

    var body: some View {
        if let usage = viewModel.usage {
            Image(nsImage: renderLabel(usage))
        } else if viewModel.errorMessage != nil {
            Text("ccm ⚠️")
        } else {
            Text("ccm: --")
        }
    }

    private func renderLabel(
        _ usage: FetchUsageResponse
    ) -> NSImage {
        let fiveHour = usage.fiveHour?.utilization ?? 0
        let sevenDay = usage.sevenDay?.utilization ?? 0

        let content = HStack(spacing: 3) {
            DonutChartView(
                innerValue: Double(fiveHour),
                outerValue: Double(sevenDay)
            )
            VStack(alignment: .leading, spacing: 0) {
                Text("\(fiveHour)%")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.black)
                Text("\(sevenDay)%")
                    .font(.system(size: 9))
                    .foregroundStyle(.black)
            }
        }

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        return renderer.nsImage ?? NSImage()
    }

    private func colorFor(_ pct: Int) -> Color {
        if pct < 50 { return .green }
        if pct < 75 { return .yellow }
        return .red
    }
}
