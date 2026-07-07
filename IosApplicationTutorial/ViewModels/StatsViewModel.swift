import Foundation
import Combine

// MARK: - StatsViewModel
/// Derives all computed stats from SessionStore and exposes them
/// as simple properties for StatsTab to display.
final class StatsViewModel: ObservableObject {

    private var store: SessionStore { SessionStore.shared }


    // MARK: Aggregate totals
    var totalGamesPlayed: Int  { store.sessions.count }
    var totalScore: Int        { store.sessions.reduce(0) { $0 + $1.score } }

    // MARK: Per-mode personal bests
    var bestTapFrenzy: Int {
        store.sessions.filter { $0.mode == .tapFrenzy }.map(\.score).max() ?? 0
    }
    var bestLightItUp: Int {
        store.sessions.filter { $0.mode == .lightItUp }.map(\.score).max() ?? 0
    }
    var bestQuizRush: Int {
        store.sessions.filter { $0.mode == .quizRush  }.map(\.score).max() ?? 0
    }
    func best(for mode: GameMode) -> Int {
        store.sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    // MARK: Recent games (most-recent first, capped at 10)
    var recentSessions: [GameSession] {
        Array(store.sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10))
    }

    // MARK: Chart data (all sessions, sorted by timestamp)
    var chartSessions: [GameSession] {
        store.sessions.sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: All sessions (for the chart)
    var sessions: [GameSession] { store.sessions }
}
