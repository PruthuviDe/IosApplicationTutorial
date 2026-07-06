import SwiftUI

enum GameMode: String, Codable, CaseIterable {
    case tapFrenzy  = "Tap Frenzy"
    case lightItUp  = "Light It Up"
    case quizRush   = "Quiz Rush"

    var icon: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush:  return "questionmark.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .tapFrenzy: return .red
        case .lightItUp: return .cyan
        case .quizRush:  return .purple
        }
    }

    var subtitle: String {
        switch self {
        case .tapFrenzy: return "Tap fast, build combos"
        case .lightItUp: return "Find the glowing card"
        case .quizRush:  return "Answer trivia questions"
        }
    }
}
