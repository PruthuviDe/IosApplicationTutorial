import SwiftUI
import Combine

final class LightItUpViewModel: ObservableObject {

    @Published var cards: [Card]   = [Card(), Card(), Card()]
    @Published var score           = 0
    @Published var timeRemaining   = 60
    @Published var lives           = 3
    @Published var gameStarted     = false
    @Published var showLevelFlash  = false
    @Published var flashMessage    = ""
    @Published var flashColor: Color = .cyan
    @Published var isTransitioning = false

    @AppStorage("lightItUpHighScore") var highScore = 0
    @AppStorage("roundLength")        var roundLength = 60

    private var lightAccumulator = 0.0
    private var prevLevel: Level = .L1

    let countdownTimer = Timer.publish(every: 1,   on: .main, in: .common).autoconnect()
    let lightTimer     = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var currentLevel: Level {
        let elapsed = roundLength - timeRemaining
        let quarter = roundLength / 4
        if elapsed < quarter          { return .L1 }
        if elapsed < quarter * 2      { return .L2 }
        if elapsed < quarter * 3      { return .L3 }
        return .L4
    }

    var isGameOver: Bool { timeRemaining == 0 || lives == 0 }

    var gridColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(100)), count: currentLevel.columns)
    }

    func startGame() {
        timeRemaining = roundLength
        gameStarted   = true
        prevLevel     = .L1
    }

    func countdownTick() {
        guard gameStarted && timeRemaining > 0 else { return }

        let before = currentLevel
        timeRemaining -= 1
        let after  = currentLevel

        if after != before {
            for i in 0..<cards.count { cards[i].isLit = false }
            cards            = Array(repeating: Card(), count: after.cardCount)
            lightAccumulator = 0
            isTransitioning  = true

            flashMessage  = after.name.uppercased() + "!"
            flashColor    = after.glowColor
            withAnimation(.easeInOut(duration: 0.35)) { showLevelFlash = true }

            Task {
                try? await Task.sleep(for: .seconds(1.2))
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.35)) { showLevelFlash = false }
                    isTransitioning = false
                }
            }
        }
    }

    func lightTick() {
        guard gameStarted && lives > 0 && !isTransitioning else { return }
        lightAccumulator += 0.4

        guard lightAccumulator >= currentLevel.litWindow else { return }
        lightAccumulator = 0

        var anyMissed = false
        for i in 0..<cards.count {
            if cards[i].isLit { anyMissed = true }
            cards[i].isLit = false
        }
        if anyMissed { lives -= 1 }

        if lives > 0 && safeToLightCard {
            let indices = cards.indices.shuffled()
            for i in 0..<min(currentLevel.litCount, indices.count) {
                cards[indices[i]].isLit = true
            }
        }
    }

    func tapCard(index: Int) {
        guard index < cards.count else { return }
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            lives -= 1
            for i in 0..<cards.count { cards[i].isLit = false }
        }
    }

    func saveSession() {
        if score > highScore { highScore = score }
        let loc = LocationService.shared.coordinate
        SessionStore.shared.save(session: GameSession(
            mode: .lightItUp,
            score: score,
            latitude: loc.latitude,
            longitude: loc.longitude
        ))
    }

    func restart() {
        score            = 0
        timeRemaining    = roundLength
        gameStarted      = true
        lives            = 3
        lightAccumulator = 0
        cards            = [Card(), Card(), Card()]
        showLevelFlash   = false
        isTransitioning  = false
    }

    private var safeToLightCard: Bool {
        if currentLevel == .L4 { return true }
        let elapsed   = roundLength - timeRemaining
        let quarter   = roundLength / 4
        let levelEnd: Int
        switch currentLevel {
        case .L1: levelEnd = quarter
        case .L2: levelEnd = quarter * 2
        case .L3: levelEnd = quarter * 3
        case .L4: return true
        }
        return Double(levelEnd - elapsed) > currentLevel.litWindow
    }
}
