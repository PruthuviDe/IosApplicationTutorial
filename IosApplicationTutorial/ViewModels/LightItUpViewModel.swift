import SwiftUI
import Combine

final class LightItUpViewModel: ObservableObject {

    // MARK: - Published State

    @Published var cards:         [Card]   = []
    @Published var score:         Int      = 0
    @Published var lives:         Int      = 3
    @Published var timeRemaining: Int      = 0
    @Published var gameStarted:   Bool     = false
    @Published var wrongFlash:    Bool     = false
    @Published var showBanner:    Bool     = false
    @Published var bannerMessage: String   = ""
    @Published var bannerColor:   Color    = .cyan

    /// Target colour shown in the hint bar (colour mode).
    @Published var targetColor:     CardColor    = .cyan
    /// Sequence the player must tap through (sequence mode).
    @Published var sequenceTarget:  [CardColor]  = []
    /// Which step of the sequence the player is on.
    @Published var sequenceStep:    Int          = 0

    // MARK: - Game Configuration

    /// Round length in seconds. 0 = Endless mode (no timer).
    let roundLength: Int

    // MARK: - Timers

    /// Fires every 0.4 s — drives the card light/dark cycle.
    let lightTimer     = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    /// Fires every 1 s — used only when roundLength > 0 (Timed mode).
    let countdownTimer = Timer.publish(every: 1,   on: .main, in: .common).autoconnect()

    // MARK: - Internal Bookkeeping

    private var lightAccumulator = 0.0
    private var lastCardCount    = 3

    // MARK: - Init

    init(roundLength: Int = 0) {
        self.roundLength = roundLength
    }

    // MARK: - Computed

    /// All difficulty parameters are derived from the current score.
    var difficulty: DifficultySnapshot { .compute(score: score) }

    var isGameOver: Bool {
        lives == 0 || (roundLength > 0 && timeRemaining == 0 && gameStarted)
    }

    var gridColumns: [GridItem] {
        // 4 cards → 2×2 square; everything else → 3 columns
        let cols = difficulty.cardCount == 4 ? 2 : 3
        return Array(repeating: GridItem(.fixed(82)), count: cols)
    }

    // MARK: - Game Control

    func startGame() {
        score            = 0
        lives            = 3
        timeRemaining    = roundLength
        lightAccumulator = 0
        lastCardCount    = 3
        wrongFlash       = false
        showBanner       = false
        targetColor      = .cyan
        sequenceTarget   = []
        sequenceStep     = 0
        cards            = makeCards(count: 3)
        gameStarted      = true
    }

    func restart() { startGame() }

    // MARK: - Timer Ticks

    /// Called every 1 s in Timed mode. Does nothing in Endless mode.
    func countdownTick() {
        guard gameStarted && roundLength > 0 && timeRemaining > 0 else { return }
        timeRemaining -= 1
    }

    /// Called every 0.4 s — drives the light/dark cycle for cards.
    func lightTick() {
        guard gameStarted && !isGameOver else { return }
        let diff = difficulty

        // Grid grows when score crosses the next threshold.
        if diff.cardCount != lastCardCount {
            lastCardCount    = diff.cardCount
            cards            = makeCards(count: diff.cardCount)
            lightAccumulator = 0
            sequenceTarget   = []
            sequenceStep     = 0
            showMilestoneBanner(diff: diff)
            return
        }

        lightAccumulator += 0.4
        guard lightAccumulator >= diff.litWindow else { return }
        lightAccumulator = 0

        // Any card still lit when the window closes = missed it.
        let anyMissed = cards.contains { $0.isLit }
        clearAllLit()

        if anyMissed {
            lives        -= 1
            flashWrong()
            sequenceTarget = []
            sequenceStep   = 0
            return
        }

        guard lives > 0 else { return }
        lightNewCards(diff: diff)
    }

    // MARK: - Player Tap

    func tapCard(index: Int) {
        guard index < cards.count, cards[index].isLit else { return }
        let diff = difficulty

        if diff.sequenceLength > 0 && !sequenceTarget.isEmpty {
            // ── Sequence mode ──────────────────────────────────────────
            let tapped   = cards[index].color
            let expected = sequenceTarget[sequenceStep]

            if tapped == expected {
                cards[index].isLit = false
                sequenceStep      += 1
                lightAccumulator   = 0   // reset timer so player has time for next step

                if sequenceStep >= sequenceTarget.count {
                    // Sequence complete — award bonus points.
                    score         += sequenceTarget.count
                    sequenceTarget = []
                    sequenceStep   = 0
                }
            } else {
                lives -= 1
                flashWrong()
                clearAllLit()
                sequenceTarget = []
                sequenceStep   = 0
            }

        } else {
            // ── Simple / colour mode ────────────────────────────────────
            let tapped = cards[index].color

            if diff.colorCount > 1 && tapped != targetColor {
                // Tapped a decoy card of the wrong colour.
                lives -= 1
                flashWrong()
                clearAllLit()
            } else {
                cards[index].isLit = false
                score += 1
            }
        }
    }

    // MARK: - Session Save

    func saveSession() {
        let loc = LocationService.shared.coordinate
        SessionStore.shared.save(session: GameSession(
            mode:      .lightItUp,
            score:     score,
            latitude:  loc.latitude,
            longitude: loc.longitude
        ))
    }

    // MARK: - Private Helpers

    private func lightNewCards(diff: DifficultySnapshot) {
        let available = Array(CardColor.allCases.prefix(diff.colorCount))

        if diff.sequenceLength > 0 {
            // Sequence mode: unique-colour sequence, one card lit per colour.
            let seqLen     = min(diff.sequenceLength, available.count)
            sequenceTarget = available.shuffled().prefix(seqLen).map { $0 }
            sequenceStep   = 0

            var freeIndices = cards.indices.shuffled()
            for color in sequenceTarget {
                guard let i = freeIndices.first else { break }
                cards[i].isLit = true
                cards[i].color = color
                freeIndices.removeFirst()
            }

        } else if diff.colorCount > 1 {
            // Colour mode: one target + optional decoys.
            let tgt     = available.randomElement()!
            targetColor = tgt

            var indices = cards.indices.shuffled()
            if let first = indices.first {
                cards[first].isLit = true
                cards[first].color = tgt
                indices.removeFirst()
            }
            for i in 0..<min(diff.litCount - 1, indices.count) {
                cards[indices[i]].isLit = true
                cards[indices[i]].color = available.randomElement()!
            }

        } else {
            // Simple mode: light up litCount cards, all cyan.
            let indices = cards.indices.shuffled()
            for i in 0..<min(diff.litCount, indices.count) {
                cards[indices[i]].isLit  = true
                cards[indices[i]].color  = .cyan
            }
        }
    }

    private func makeCards(count: Int) -> [Card] {
        Array(repeating: Card(), count: count)
    }

    private func clearAllLit() {
        for i in 0..<cards.count { cards[i].isLit = false }
    }

    private func flashWrong() {
        wrongFlash = true
        Task {
            try? await Task.sleep(for: .seconds(0.4))
            await MainActor.run { wrongFlash = false }
        }
    }

    private func showMilestoneBanner(diff: DifficultySnapshot) {
        bannerMessage = "Level Up!"
        bannerColor   = diff.accentColor
        withAnimation(.easeInOut(duration: 0.35)) { showBanner = true }
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.35)) { showBanner = false }
            }
        }
    }
}
