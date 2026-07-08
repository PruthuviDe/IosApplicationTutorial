import SwiftUI
import Combine

final class TapFrenzyViewModel: ObservableObject {
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

    @AppStorage("tapFrenzyHighScore") var highScore = 0

    private var lastTapTime    = Date()
    private var bonusBurstStart = 5

    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    func handleTap() {
        if !gameStarted {
            gameStarted = true
            bonusBurstStart = Int.random(in: 4...8)
        }

        buttonPressed = true
        Task {
            try? await Task.sleep(for: .seconds(0.12))
            await MainActor.run { buttonPressed = false }
        }

        let now = Date()
        if now.timeIntervalSince(lastTapTime) < 0.8 {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }
        lastTapTime = now

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

    func tick() {
        guard gameStarted && timeRemaining > 0 else { return }
        timeRemaining -= 1
        buttonType = .random
        withAnimation(.easeInOut(duration: 0.30)) {
            buttonOffsetX = Double.random(in: -75...75)
            buttonOffsetY = Double.random(in: -45...180)
        }

        if Date().timeIntervalSince(lastTapTime) > 1.0 {
            comboMultiplier = 1
        }
        if timeRemaining == bonusBurstStart     { isBonusBurst = true }
        if timeRemaining == bonusBurstStart - 2 { isBonusBurst = false }

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
