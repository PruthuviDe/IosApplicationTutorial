import SwiftUI

// MARK: - TapButtonType
/// Describes the current type of the tap target in Tap Frenzy.
/// Using an enum instead of a raw Int makes the intent explicit and
/// eliminates magic-number comparisons throughout the view.
enum TapButtonType: CaseIterable {
    /// Standard tap — scores comboMultiplier points.
    case normal
    /// Bonus tap — scores 3× points; double during burst mode.
    case bonus
    /// Trap tap — deducts points and resets the combo multiplier.
    case trap

    /// Returns a random button type.
    static var random: TapButtonType {
        TapButtonType.allCases.randomElement() ?? .normal
    }

    /// Label shown inside the tap button.
    var label: String {
        switch self {
        case .normal: return "NORMAL"
        case .bonus:  return "BONUS"
        case .trap:   return "TRAP"
        }
    }

    /// Score modifier label shown below the main label.
    func scoreLabel(combo: Int) -> String {
        switch self {
        case .normal: return "+\(combo)"
        case .bonus:  return "+3"
        case .trap:   return "-1"
        }
    }

    /// Accent colour of the tap button.
    var color: Color {
        switch self {
        case .normal: return Color(red: 0.92, green: 0.26, blue: 0.35)   // coral red
        case .bonus:  return Color(red: 0.20, green: 0.83, blue: 0.52)   // green
        case .trap:   return Color(red: 0.65, green: 0.68, blue: 0.80)   // steel grey
        }
    }
}
