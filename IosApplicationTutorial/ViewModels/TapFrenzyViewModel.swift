import SwiftUI
import Combine

// MARK: - TapFrenzyViewModel
/// Owns all mutable state for a Tap Frenzy round and exposes
/// intent-level methods so TapFrenzyView stays pure rendering.
final class TapFrenzyViewModel: ObservableObject {

    // MARK: Published state
    @Published var score           = 0
    @Published var timeRemaining   = 10
    @Published var comboMultiplier = 1
    @Published var buttonType: TapButtonType = .normal
    @Published var buttonOffsetX   = 0.0
    @Published var buttonOffsetY   = 0.0
    @Published var isBonusBurst    = false
    @Published var gameStarted     = false
    @Published var isNewHighScore  = false
    @Published var buttonPressed   = false

    // MARK: Persisted high score
    @AppStorage("tapFrenzyHighScore") var highScore = 0

    // MARK: Private state
    private var lastTapTime    = Date()
    private var bonusBurstStart = 5

    // MARK: - Timer
    /// The 1-second countdown timer; observed via `.onReceive` in the view.
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    // MARK: - Intent: handle a tap on the main button
    func handleTap() {
        if !gameStarted {
            gameStarted = true
            bonusBurstStart = Int.random(in: 4...8)
        }

        // Animate press-down
        buttonPressed = true
        Task {
            try? await Task.sleep(for: .seconds(0.12))
            await MainActor.run { buttonPressed = false }
        }

        // Combo logic
        let now = Date()
        if now.timeIntervalSince(lastTapTime) < 0.8 {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }
        lastTapTime = now

        // Scoring
        switch buttonType {
        case .bonus:
            score += (isBonusBurst ? 6 : 3) * comboMultiplier
        case .trap:
            score = max(0, score - comboMultiplier)
            comboMultiplier = 1
        case .normal:
            score += isBonusBurst ? comboMultiplier * 2 : comboMultiplier
        }
    }

    // MARK: - Intent: process each 1-second timer tick
    func tick() {
        guard gameStarted && timeRemaining > 0 else { return }
        timeRemaining -= 1

        // Rotate button type and move it
        buttonType = .random
        withAnimation(.easeInOut(duration: 0.30)) {
            buttonOffsetX = Double.random(in: -75...75)
            buttonOffsetY = Double.random(in: -45...180)
        }

        // Reset combo if player hasn't tapped recently
        if Date().timeIntervalSince(lastTapTime) > 1.0 {
            comboMultiplier = 1
        }

        // Burst mode window
        if timeRemaining == bonusBurstStart     { isBonusBurst = true }
        if timeRemaining == bonusBurstStart - 2 { isBonusBurst = false }

        // Game over
        if timeRemaining == 0 {
            isNewHighScore = score > highScore
            if isNewHighScore { highScore = score }

            let loc = LocationService.shared.coordinate
            SessionStore.shared.save(session: GameSession(
                mode: .tapFrenzy,
                score: score,
                latitude: loc.latitude,
                longitude: loc.longitude
            ))
        }
    }

    // MARK: - Intent: restart
    func restart() {
        score           = 0
        timeRemaining   = 10
        comboMultiplier = 1
        lastTapTime     = Date()
        buttonType      = .normal
        gameStarted     = false
        isNewHighScore  = false
        isBonusBurst    = false
        bonusBurstStart = 5
        buttonOffsetX   = 0.0
        buttonOffsetY   = 0.0
        buttonPressed   = false
    }
}
