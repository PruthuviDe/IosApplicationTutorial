import SwiftUI

enum CardColor: CaseIterable, Equatable {
    case cyan, green, orange, red

    var uiColor: Color {
        switch self {
        case .cyan:   return Color(red: 0.20, green: 0.83, blue: 0.95)
        case .green:  return Color(red: 0.20, green: 0.83, blue: 0.52)
        case .orange: return Color(red: 0.95, green: 0.60, blue: 0.20)
        case .red:    return Color(red: 0.92, green: 0.26, blue: 0.35)
        }
    }


    var displayName: String {
        switch self {
        case .cyan:   return "Blue"
        case .green:  return "Green"
        case .orange: return "Orange"
        case .red:    return "Red"
        }
    }
}

struct Card: Identifiable {
    let id    = UUID()
    var isLit = false
    var color: CardColor = .cyan
}
