import SwiftUI
import Combine

struct TimedLevelSnapshot {
    let level:       Int
    let cardCount:   Int
    let litWindow:   Double
    let litCount:    Int
    let colorCount:  Int
    let accentColor: Color

    static func compute(timeRemaining: Int, roundLength: Int) -> TimedLevelSnapshot {
        let elapsed = roundLength - timeRemaining
        let fraction = roundLength > 0 ? Double(elapsed) / Double(roundLength) : 0

        let level: Int
        switch fraction {
        case ..<0.25: level = 1
        case ..<0.50: level = 2
        case ..<0.75: level = 3
        default:      level = 4
        }

        let palette: [Color] = [
            Color(red: 0.20, green: 0.83, blue: 0.95),
            Color(red: 0.20, green: 0.83, blue: 0.52),
            Color(red: 0.95, green: 0.60, blue: 0.20),
            Color(red: 0.92, green: 0.26, blue: 0.35)
        ]

        switch level {
        case 1: return TimedLevelSnapshot(level: 1, cardCount: 3, litWindow: 1.5, litCount: 1, colorCount: 1, accentColor: palette[0])
        case 2: return TimedLevelSnapshot(level: 2, cardCount: 4, litWindow: 1.2, litCount: 1, colorCount: 2, accentColor: palette[1])
        case 3: return TimedLevelSnapshot(level: 3, cardCount: 6, litWindow: 1.0, litCount: 1, colorCount: 3, accentColor: palette[2])
        default: return TimedLevelSnapshot(level: 4, cardCount: 9, litWindow: 0.8, litCount: 2, colorCount: 4, accentColor: palette[3])
        }
    }
}

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

    private var lightAccumulator  = 0.0
    private var lastCardCount     = 3
    private var lastTimedLevel    = 0

    init(roundLength: Int = 0) {
        self.roundLength = roundLength
    }

    var difficulty: DifficultySnapshot { .compute(score: score) }

    var timedLevel: TimedLevelSnapshot {
        TimedLevelSnapshot.compute(timeRemaining: timeRemaining, roundLength: roundLength)
    }

    var levelNumber: Int {
        roundLength > 0 ? timedLevel.level : (score / 5 + 1)
    }
    var levelAccentColor: Color {
        roundLength > 0 ? timedLevel.accentColor : difficulty.accentColor
    }

    var isGameOver: Bool {
        lives == 0 || (roundLength > 0 && timeRemaining == 0 && gameStarted)
    }

    var gridColumns: [GridItem] {
        let count = roundLength > 0 ? timedLevel.cardCount : difficulty.cardCount
        let cols = count <= 4 ? 2 : 3
        return Array(repeating: GridItem(.fixed(82)), count: cols)
    }

    func startGame() {
        score            = 0
        lives            = 3
        timeRemaining    = roundLength
        lightAccumulator = 0
        lastCardCount    = 3
        lastTimedLevel   = 1
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

        let cardCount:  Int
        let litWindow:  Double
        let litCount:   Int
        let colorCount: Int

        if roundLength > 0 {
            let tl = timedLevel
            cardCount  = tl.cardCount
            litWindow  = tl.litWindow
            litCount   = tl.litCount
            colorCount = tl.colorCount

            if tl.level != lastTimedLevel {
                lastTimedLevel = tl.level
                lastCardCount = cardCount
                cards         = makeCards(count: cardCount)
                lightAccumulator = 0
                sequenceTarget   = []
                sequenceStep     = 0
                showTimedLevelBanner(level: tl.level, color: tl.accentColor)
                return
            }
        } else {
            let diff = difficulty
            cardCount  = diff.cardCount
            litWindow  = diff.litWindow
            litCount   = diff.litCount
            colorCount = diff.colorCount

            if cardCount != lastCardCount {
                lastCardCount    = cardCount
                cards            = makeCards(count: cardCount)
                lightAccumulator = 0
                sequenceTarget   = []
                sequenceStep     = 0
                showMilestoneBanner(diff: diff)
                return
            }
        }

        lightAccumulator += 0.4
        guard lightAccumulator >= litWindow else { return }
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

        let availableColors = Array(CardColor.allCases.prefix(colorCount))
        let seqLen = roundLength > 0 ? 0 : difficulty.sequenceLength
        lightNewCardsRaw(litCount: litCount, colorCount: colorCount, availableColors: availableColors, sequenceLength: seqLen)
    }

    func tapCard(index: Int) {
        guard index < cards.count, cards[index].isLit else { return }
        let diff = difficulty

        let currentColorCount = roundLength > 0 ? timedLevel.colorCount : difficulty.colorCount
        let currentSeqLen = roundLength > 0 ? 0 : difficulty.sequenceLength

        if currentSeqLen > 0 && !sequenceTarget.isEmpty {
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

            if currentColorCount > 1 && tapped != targetColor {
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

    private func showTimedLevelBanner(level: Int, color: Color) {
        bannerMessage = "LEVEL \(level)"
        bannerColor   = color
        withAnimation(.easeInOut(duration: 0.35)) { showBanner = true }
        Task {
            try? await Task.sleep(for: .seconds(1.4))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.35)) { showBanner = false }
            }
        }
    }

    private func lightNewCardsRaw(litCount: Int, colorCount: Int, availableColors: [CardColor], sequenceLength: Int) {
        if sequenceLength > 0 {
            let seqLen     = min(sequenceLength, availableColors.count)
            sequenceTarget = availableColors.shuffled().prefix(seqLen).map { $0 }
            sequenceStep   = 0

            var freeIndices = cards.indices.shuffled()
            for color in sequenceTarget {
                guard let i = freeIndices.first else { break }
                cards[i].isLit = true
                cards[i].color = color
                freeIndices.removeFirst()
            }

        } else if colorCount > 1 {
            let tgt     = availableColors.randomElement()!
            targetColor = tgt

            var indices = cards.indices.shuffled()
            if let first = indices.first {
                cards[first].isLit = true
                cards[first].color = tgt
                indices.removeFirst()
            }
            for i in 0..<min(litCount - 1, indices.count) {
                cards[indices[i]].isLit = true
                cards[indices[i]].color = availableColors.randomElement()!
            }

        } else {
            let indices = cards.indices.shuffled()
            for i in 0..<min(litCount, indices.count) {
                cards[indices[i]].isLit = true
                cards[indices[i]].color = .cyan
            }
        }
    }
}
