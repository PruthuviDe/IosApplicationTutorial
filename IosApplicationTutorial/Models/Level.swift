import SwiftUI


enum Level: CaseIterable {
    case L1, L2, L3, L4

    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .L1: return 3
        case .L2: return 2
        case .L3: return 3
        case .L4: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }

    var litCount: Int {
        switch self {
        case .L4: return 2
        default:  return 1
        }
    }

    var name: String {
        switch self {
        case .L1: return "Level 1"
        case .L2: return "Level 2"
        case .L3: return "Level 3"
        case .L4: return "Level 4"
        }
    }

    var glowColor: Color {
        switch self {
        case .L1: return Color(red: 0.20, green: 0.83, blue: 0.95) 
        case .L2: return Color(red: 0.20, green: 0.83, blue: 0.52) 
        case .L3: return Color(red: 0.95, green: 0.60, blue: 0.20) 
        case .L4: return Color(red: 0.92, green: 0.26, blue: 0.35) 
        }
    }
}
