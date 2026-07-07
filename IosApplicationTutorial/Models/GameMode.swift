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

    var imageName: String {
        switch self {
        case .tapFrenzy: return "tap_frenzy"
        case .lightItUp: return "light_it_up"
        case .quizRush:  return "quiz_rush"
        }
    }

    var accentColor: Color {
        switch self {
        case .tapFrenzy: return Color(red: 0.92, green: 0.26, blue: 0.35)
        case .lightItUp: return Color(red: 0.20, green: 0.83, blue: 0.95)
        case .quizRush:  return Color(red: 0.65, green: 0.35, blue: 0.95)
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
