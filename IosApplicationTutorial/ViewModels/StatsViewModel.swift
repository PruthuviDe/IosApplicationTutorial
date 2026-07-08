import Foundation
import Combine

// MARK: - StatsViewModel
/// Derives all computed stats from SessionStore and exposes them
/// as simple properties for StatsTab to display.
/// Subscribes to SessionStore's objectWillChange publisher so that
/// StatsTab re-renders whenever a new session is saved.
final class StatsViewModel: ObservableObject {

    private let store = SessionStore.shared
    private var cancellable: AnyCancellable?

    init() {
        // Forward SessionStore change notifications to StatsViewModel's
        // objectWillChange so any observing View re-renders automatically.
        cancellable = store.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    // MARK: Aggregate totals
    var totalGamesPlayed: Int { store.sessions.count }
    var totalScore: Int       { store.sessions.reduce(0) { $0 + $1.score } }

    // MARK: Per-mode personal bests
    func best(for mode: GameMode) -> Int {
        store.sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    // MARK: Recent games (most-recent first, capped at 10)
    var recentSessions: [GameSession] {
        Array(store.sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10))
    }

    // MARK: Chart data (all sessions, sorted by timestamp ascending)
    var chartSessions: [GameSession] {
        store.sessions.sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: All sessions
    var sessions: [GameSession] { store.sessions }
}
