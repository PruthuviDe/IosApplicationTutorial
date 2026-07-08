import SwiftUI

enum TapButtonType: CaseIterable {
    case normal
    case bonus
    case trap

    static var random: TapButtonType {
        TapButtonType.allCases.randomElement() ?? .normal
    }

    var label: String {
        switch self {
        case .normal: return "NORMAL"
        case .bonus:  return "BONUS"
        case .trap:   return "TRAP"
        }
    }

    func scoreLabel(combo: Int) -> String {
        switch self {
        case .normal: return "+\(combo)"
        case .bonus:  return "+3"
        case .trap:   return "-1"
        }
    }

    var color: Color {
        switch self {
        case .normal: return Color(red: 0.92, green: 0.26, blue: 0.35)  
        case .bonus:  return Color(red: 0.20, green: 0.83, blue: 0.52)  
        case .trap:   return Color(red: 0.65, green: 0.68, blue: 0.80)  
        }
    }
}
