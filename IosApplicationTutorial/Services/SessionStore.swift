import Foundation
import Combine

class SessionStore: ObservableObject {

    static let shared = SessionStore()

    @Published private(set) var sessions: [GameSession] = []
    @Published var isTabBarHidden: Bool = false

    private let key = "gameSessions"

    init() {
        sessions = load()
    }

    func save(session: GameSession) {
        sessions.append(session)
        persist()
    }
    func resetAll() {
        sessions = []
        persist()
    }

    var totalGamesPlayed: Int { sessions.count }

    var activeStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let sessionsByDay = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }
        
        var completedDates = Set<Date>()
        for (day, daySessions) in sessionsByDay {
            let weekday = calendar.component(.weekday, from: day)
            let targetGame: GameMode
            let targetScore: Int
            
            switch weekday {
            case 1, 4: 
                targetGame = .tapFrenzy
                targetScore = 1000
            case 2, 5: 
                targetGame = .lightItUp
                targetScore = 15
            default: 
                targetGame = .quizRush
                targetScore = 50
            }
            
            let completed = daySessions.contains { session in
                session.mode == targetGame && session.score >= targetScore
            }
            
            if completed {
                completedDates.insert(day)
            }
        }
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
        
        if !completedDates.contains(today) && !completedDates.contains(yesterday) {
            return 0
        }
        
        var currentStreak = 0
        var dateToCheck = completedDates.contains(today) ? today : yesterday
        
        while completedDates.contains(dateToCheck) {
            currentStreak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dateToCheck) else { break }
            dateToCheck = previousDay
        }
        
        return currentStreak
    }

    var totalScore: Int { sessions.reduce(0) { $0 + $1.score } }

    func highScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }

    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }

    var recentSessions: [GameSession] {
        sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10).map { $0 }
    }

    private func load() -> [GameSession] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([GameSession].self, from: data)
        else { return [] }
        return decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
