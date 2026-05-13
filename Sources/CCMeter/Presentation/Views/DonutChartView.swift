import SwiftUI

struct DonutChartView: View {
    let innerValue: Double
    let outerValue: Double

    private let size: CGFloat = 18
    private let outerWidth: CGFloat = 4
    private var innerRadius: CGFloat { size / 2 - outerWidth }

    var body: some View {
        ZStack {
            outerRing
            innerDisc
        }
        .frame(width: size, height: size)
    }

    private var outerRing: some View {
        let radius = (size - outerWidth) / 2
        let fraction = min(max(outerValue / 100.0, 0), 1)
        return ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: outerWidth)
                .frame(width: radius * 2, height: radius * 2)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    colorFor(outerValue),
                    style: StrokeStyle(
                        lineWidth: outerWidth,
                        lineCap: .round
                    )
                )
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(-90))
        }
    }

    private var innerDisc: some View {
        let fraction = min(max(innerValue / 100.0, 0), 1)
        let endAngle = Angle.degrees(360 * fraction - 90)
        return ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: innerRadius * 2, height: innerRadius * 2)
            PieSlice(endAngle: endAngle)
                .fill(colorFor(innerValue))
                .frame(width: innerRadius * 2, height: innerRadius * 2)
        }
    }

    private func colorFor(_ value: Double) -> Color {
        if value < 50 { return .green }
        if value < 75 { return Color.orange }
        return .red
    }
}

private struct PieSlice: Shape {
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
