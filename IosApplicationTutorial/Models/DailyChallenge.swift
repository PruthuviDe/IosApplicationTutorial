import SwiftUI

struct DailyChallenge {
    let title: String
    let description: String
    let gameMode: GameMode
    let targetScore: Int
    
    var icon: String { gameMode.icon }
    var color: Color { gameMode.accentColor }
}

enum DailyChallengeManager {
    static func currentChallenge() -> DailyChallenge {
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: Date())
        
        switch day {
        case 1, 4: 
            return DailyChallenge(
                title: "Frenzy Fever",
                description: "Score 1,000+ points in Tap Frenzy",
                gameMode: .tapFrenzy,
                targetScore: 1000
            )
        case 2, 5: 
            return DailyChallenge(
                title: "Reflex Master",
                description: "Score 15+ points in Light It Up",
                gameMode: .lightItUp,
                targetScore: 15
            )
        default: 
            return DailyChallenge(
                title: "Trivia Brain",
                description: "Score 50+ points in Quiz Rush",
                gameMode: .quizRush,
                targetScore: 50
            )
        }
    }
    
    static func isCompleted(sessions: [GameSession]) -> Bool {
        let challenge = currentChallenge()
        let today = Calendar.current.startOfDay(for: Date())
        
        return sessions.contains { session in
            let sessionDay = Calendar.current.startOfDay(for: session.timestamp)
            return sessionDay == today &&
                   session.mode == challenge.gameMode &&
                   session.score >= challenge.targetScore
        }
    }
}
