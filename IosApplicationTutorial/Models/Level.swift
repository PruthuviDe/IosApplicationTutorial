import SwiftUI

// MARK: - Level Model
/// Represents the four difficulty levels inside a Light It Up round.
/// All levels play out inside a single round — difficulty ramps automatically.
enum Level: CaseIterable {
    case L1, L2, L3, L4

    /// Number of cards shown in the grid at this level.
    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }

    /// Number of grid columns at this level.
    var columns: Int {
        switch self {
        case .L1: return 3
        case .L2: return 2
        case .L3: return 3
        case .L4: return 3
        }
    }

    /// How long (seconds) a card stays lit before the player misses it.
    var litWindow: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }

    /// How many cards light up simultaneously at this level.
    var litCount: Int {
        switch self {
        case .L4: return 2
        default:  return 1
        }
    }

    /// Human-readable name shown in the HUD.
    var name: String {
        switch self {
        case .L1: return "Level 1"
        case .L2: return "Level 2"
        case .L3: return "Level 3"
        case .L4: return "Level 4"
        }
    }

    /// Unique accent / glow colour that changes as the player progresses.
    var glowColor: Color {
        switch self {
        case .L1: return Color(red: 0.20, green: 0.83, blue: 0.95)   // cyan
        case .L2: return Color(red: 0.20, green: 0.83, blue: 0.52)   // green
        case .L3: return Color(red: 0.95, green: 0.60, blue: 0.20)   // orange
        case .L4: return Color(red: 0.92, green: 0.26, blue: 0.35)   // red
        }
    }
}
