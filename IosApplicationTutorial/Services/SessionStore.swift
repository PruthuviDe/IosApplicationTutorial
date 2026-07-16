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
        guard let latestSession = sessions.sorted(by: { $0.timestamp > $1.timestamp }).first else { return 0 }
        
        let calendar = Calendar.current
        
        if !calendar.isDateInToday(latestSession.timestamp) && !calendar.isDateInYesterday(latestSession.timestamp) {
            return 0
        }
        
        var currentStreak = 0
        var dateToCheck = latestSession.timestamp
        let allDates = Set(sessions.map { calendar.startOfDay(for: $0.timestamp) })
        
        while allDates.contains(calendar.startOfDay(for: dateToCheck)) {
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
