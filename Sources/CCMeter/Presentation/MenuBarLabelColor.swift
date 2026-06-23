import SwiftUI

enum MenuBarLabelColor: String, CaseIterable, Sendable {
    case auto
    case black
    case white

    var displayLabel: String {
        switch self {
        case .auto: return "Auto"
        case .black: return "Black"
        case .white: return "White"
        }
    }

    func resolved(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .auto: return colorScheme == .dark ? .white : .black
        case .black: return .black
        case .white: return .white
        }
    }
}
