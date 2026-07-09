import SwiftUI
import Combine

final class LightItUpViewModel: ObservableObject {

    @Published var cards:         [Card]   = []
    @Published var score:         Int      = 0
    @Published var lives:         Int      = 3
    @Published var timeRemaining: Int      = 0
    @Published var gameStarted:   Bool     = false
    @Published var wrongFlash:    Bool     = false
    @Published var showBanner:    Bool     = false
    @Published var bannerMessage: String   = ""
    @Published var bannerColor:   Color    = .cyan

    @Published var targetColor:     CardColor    = .cyan
    @Published var sequenceTarget:  [CardColor]  = []
    @Published var sequenceStep:    Int          = 0

    let roundLength: Int

    let lightTimer     = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    let countdownTimer = Timer.publish(every: 1,   on: .main, in: .common).autoconnect()

    private var lightAccumulator = 0.0
    private var lastCardCount    = 3

    init(roundLength: Int = 0) {
        self.roundLength = roundLength
    }

    var difficulty: DifficultySnapshot { .compute(score: score) }

    var isGameOver: Bool {
        lives == 0 || (roundLength > 0 && timeRemaining == 0 && gameStarted)
    }

    var gridColumns: [GridItem] {
        let cols = difficulty.cardCount == 4 ? 2 : 3
        return Array(repeating: GridItem(.fixed(82)), count: cols)
    }

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

    func countdownTick() {
        guard gameStarted && roundLength > 0 && timeRemaining > 0 else { return }
        timeRemaining -= 1
    }
    func lightTick() {
        guard gameStarted && !isGameOver else { return }
        let diff = difficulty

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

    func tapCard(index: Int) {
        guard index < cards.count, cards[index].isLit else { return }
        let diff = difficulty

        if diff.sequenceLength > 0 && !sequenceTarget.isEmpty {
            let tapped   = cards[index].color
            let expected = sequenceTarget[sequenceStep]

            if tapped == expected {
                cards[index].isLit = false
                sequenceStep      += 1
                lightAccumulator   = 0

                if sequenceStep >= sequenceTarget.count {
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
            let tapped = cards[index].color

            if diff.colorCount > 1 && tapped != targetColor {
                lives -= 1
                flashWrong()
                clearAllLit()
            } else {
                cards[index].isLit = false
                score += 1
            }
        }
    }

    func saveSession() {
        let loc = LocationService.shared.coordinate
        SessionStore.shared.save(session: GameSession(
            mode:      .lightItUp,
            score:     score,
            latitude:  loc.latitude,
            longitude: loc.longitude
        ))
    }

    private func lightNewCards(diff: DifficultySnapshot) {
        let available = Array(CardColor.allCases.prefix(diff.colorCount))

        if diff.sequenceLength > 0 {
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
