import Foundation
import Combine

class SessionStore: ObservableObject {

    static let shared = SessionStore()

    @Published private(set) var sessions: [GameSession] = []

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
        // Set each high-score key to 0 (not removeObject) so that
        // @AppStorage property wrappers in the game ViewModels receive
        // the KVO/UserDefaults change notification and update in memory.
        // removeObject() does not reliably fire @AppStorage observers.
        for mode in GameMode.allCases {
            UserDefaults.standard.set(0, forKey: mode.highScoreKey)
        }
    }

    var totalGamesPlayed: Int { sessions.count }

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
