import SwiftUI
import Combine

final class LightItUpViewModel: ObservableObject {

    // MARK: - Published State

    @Published var cards:          [Card]      = []
    @Published var score:          Int         = 0
    @Published var lives:          Int         = 3
    @Published var gameStarted:    Bool        = false
    @Published var wrongFlash:     Bool        = false   // triggers red overlay in view
    @Published var showBanner:     Bool        = false   // "Lv.X!" milestone banner
    @Published var bannerMessage:  String      = ""
    @Published var bannerColor:    Color       = .cyan

    /// The target colour shown in the hint bar (colour / simple mode).
    @Published var targetColor: CardColor = .cyan

    /// The colour sequence the player must tap through (sequence mode).
    @Published var sequenceTarget: [CardColor] = []
    /// Which step of the sequence the player is currently on.
    @Published var sequenceStep:   Int         = 0

    // MARK: - Timer

    /// Fires every 0.4 s. Accumulated against `difficulty.litWindow`.
    let lightTimer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    // MARK: - Internal Bookkeeping

    private var lightAccumulator = 0.0
    private var lastCardCount    = 3       // detects when grid should grow

    // MARK: - Computed

    /// Difficulty is always derived from the current score — never fixed stages.
    var difficulty: DifficultySnapshot { .compute(score: score) }

    var isGameOver: Bool { lives == 0 }

    var gridColumns: [GridItem] {
        // 4 cards → 2×2 square; everything else → 3 columns
        let cols = difficulty.cardCount == 4 ? 2 : 3
        return Array(repeating: GridItem(.flexible()), count: cols)
    }

    // MARK: - Game Control

    func startGame() {
        score            = 0
        lives            = 3
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

    // MARK: - Timer Tick

    func lightTick() {
        guard gameStarted && !isGameOver else { return }
        let diff = difficulty

        // Grid grows when score crosses the next threshold — show a banner.
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
            // ── Sequence mode ─────────────────────────────────────────
            let tapped   = cards[index].color
            let expected = sequenceTarget[sequenceStep]

            if tapped == expected {
                // Correct step — dim this card and advance.
                cards[index].isLit = false
                sequenceStep      += 1
                lightAccumulator   = 0   // reset timer so player has time for next step

                if sequenceStep >= sequenceTarget.count {
                    // Entire sequence complete → bonus points.
                    score         += sequenceTarget.count
                    sequenceTarget = []
                    sequenceStep   = 0
                }
            } else {
                // Wrong colour in sequence.
                lives -= 1
                flashWrong()
                clearAllLit()
                sequenceTarget = []
                sequenceStep   = 0
            }

        } else {
            // ── Simple / colour mode ───────────────────────────────────
            let tapped = cards[index].color

            if diff.colorCount > 1 && tapped != targetColor {
                // Tapped a decoy card of the wrong colour.
                lives -= 1
                flashWrong()
                clearAllLit()
            } else {
                // Correct tap.
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

    /// Decides which cards to light up based on the current difficulty mode.
    private func lightNewCards(diff: DifficultySnapshot) {
        let available = Array(CardColor.allCases.prefix(diff.colorCount))

        if diff.sequenceLength > 0 {
            // Sequence mode: generate a unique-colour sequence, light one card per colour.
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
            // Colour mode: one target card + optional decoys.
            let tgt     = available.randomElement()!
            targetColor = tgt

            var indices = cards.indices.shuffled()
            // Guarantee at least one card of the target colour.
            if let first = indices.first {
                cards[first].isLit = true
                cards[first].color = tgt
                indices.removeFirst()
            }
            // Extra cards (litCount > 1) become decoys with random colours.
            for i in 0..<min(diff.litCount - 1, indices.count) {
                cards[indices[i]].isLit = true
                cards[indices[i]].color = available.randomElement()!
            }

        } else {
            // Simple mode: light up litCount cards, all the same colour.
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

    /// Flashes the red overlay for 0.4 s.
    private func flashWrong() {
        wrongFlash = true
        Task {
            try? await Task.sleep(for: .seconds(0.4))
            await MainActor.run { wrongFlash = false }
        }
    }

    /// Shows the "Lv.X!" banner for 1.2 s when the grid grows.
    private func showMilestoneBanner(diff: DifficultySnapshot) {
        bannerMessage = "Lv.\(score / 5 + 1)!"
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
