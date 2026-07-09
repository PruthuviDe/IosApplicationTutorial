import SwiftUI

// MARK: - CardColor
/// The colours that can appear on a lit card.
/// More colours unlock as the player's score increases.
enum CardColor: CaseIterable, Equatable {
    case cyan, green, orange, red

    /// The SwiftUI colour for this card colour.
    var uiColor: Color {
        switch self {
        case .cyan:   return Color(red: 0.20, green: 0.83, blue: 0.95)
        case .green:  return Color(red: 0.20, green: 0.83, blue: 0.52)
        case .orange: return Color(red: 0.95, green: 0.60, blue: 0.20)
        case .red:    return Color(red: 0.92, green: 0.26, blue: 0.35)
        }
    }


    /// Short display name shown alongside the emoji in the hint bar.
    var displayName: String {
        switch self {
        case .cyan:   return "Blue"
        case .green:  return "Green"
        case .orange: return "Orange"
        case .red:    return "Red"
        }
    }
}

// MARK: - Card
/// A single card in the Light It Up grid.
struct Card: Identifiable {
    let id    = UUID()
    var isLit = false
    var color: CardColor = .cyan   // colour shown only when the card is lit
}
