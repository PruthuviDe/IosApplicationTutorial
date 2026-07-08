import Foundation
import Combine

final class StatsViewModel: ObservableObject {

    private let store = SessionStore.shared
    private var cancellable: AnyCancellable?

    init() {
        cancellable = store.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    var totalGamesPlayed: Int { store.sessions.count }
    var totalScore: Int       { store.sessions.reduce(0) { $0 + $1.score } }

    func best(for mode: GameMode) -> Int {
        store.sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    var recentSessions: [GameSession] {
        Array(store.sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10))
    }
    var chartSessions: [GameSession] {
        store.sessions.sorted { $0.timestamp < $1.timestamp }
    }

    var sessions: [GameSession] { store.sessions }
}
