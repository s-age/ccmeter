import SwiftUI

struct ProgressBarView: View {
    let value: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(
                        width: geo.size.width * fraction
                    )
            }
        }
        .frame(height: 8)
    }

    private var fraction: Double {
        min(Double(value) / 100.0, 1.0)
    }

    private var barColor: Color {
        if value < 50 { return .green }
        if value < 75 { return .orange }
        return .red
    }
}
