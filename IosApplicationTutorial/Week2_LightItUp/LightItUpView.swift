import SwiftUI
import Combine

struct Card: Identifiable {
    let id = UUID()
    var isLit = false
}

enum Level {
    case L1, L2, L3, L4

    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .L1: return 3
        case .L2: return 2
        case .L3: return 3
        case .L4: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }

    var litCount: Int {
        switch self {
        case .L4: return 2
        default: return 1
        }
    }

    var name: String {
        switch self {
        case .L1: return "Level 1"
        case .L2: return "Level 2"
        case .L3: return "Level 3"
        case .L4: return "Level 4"
        }
    }

    var glowColor: Color {
        switch self {
        case .L1: return .cyan
        case .L2: return .green
        case .L3: return .orange
        case .L4: return .red
        }
    }
}

struct LightItUpView: View {

    @State private var cards = [Card(), Card(), Card()]
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var gameStarted = false
    @State private var lives = 3

    @AppStorage("lightItUpHighScore") private var highScore = 0

    @AppStorage("roundLength") private var roundLength = 60

    @State private var lightAccumulator = 0.0

    @State private var showLevelFlash = false
    @State private var flashMessage = ""
    @State private var flashColor = Color.cyan

    @State private var isTransitioning = false

    // Countdown
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Light timer
    let lightTimer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var currentLevel: Level {
        let elapsed = roundLength - timeRemaining
        let quarter = roundLength / 4
        if elapsed < quarter { return .L1 }
        if elapsed < quarter * 2 { return .L2 }
        if elapsed < quarter * 3 { return .L3 }
        return .L4
    }

    var gridColumns: [GridItem] {
        return Array(repeating: GridItem(.fixed(100)), count: currentLevel.columns)
    }

    var safeToLightCard: Bool {
        if currentLevel == .L4 { return true }
        let elapsed = roundLength - timeRemaining
        let quarter = roundLength / 4
        let levelEndElapsed: Int
        switch currentLevel {
        case .L1: levelEndElapsed = quarter
        case .L2: levelEndElapsed = quarter * 2
        case .L3: levelEndElapsed = quarter * 3
        case .L4: return true
        }
        let timeLeftInLevel = levelEndElapsed - elapsed
        return Double(timeLeftInLevel) > currentLevel.litWindow
    }

    var body: some View {

        if timeRemaining == 0 || lives == 0 {

            VStack(spacing: 24) {

                Spacer()

                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Score: \(score)")
                    .font(.title)
                    .foregroundColor(.cyan)

                Text("Best: \(highScore)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))

                if lives == 0 {
                    Text("No lives left!")
                        .foregroundColor(.red)
                }

                Button("Play Again") {
                    restartGame()
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cyan)
                .cornerRadius(12)
                .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .onAppear {

                if score > highScore {
                    highScore = score
                }
            }

        } else {

            VStack(spacing: 20) {

                HStack {

                    Text(currentLevel.name)
                        .font(.headline)
                        .foregroundColor(currentLevel.glowColor)

                    Spacer()

                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < lives ? "heart.fill" : "heart")
                                .foregroundColor(index < lives ? .red : .gray)
                        }
                    }
                    .font(.title3)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Score: \(score)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("\(timeRemaining)s")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                Spacer()

                HStack {
                    Spacer()
                    LazyVGrid(columns: gridColumns, spacing: 16) {

                        ForEach(0..<cards.count, id: \.self) { index in

                            RoundedRectangle(cornerRadius: 12)
                                .fill(cards[index].isLit ? currentLevel.glowColor : Color(red: 0.15, green: 0.2, blue: 0.35))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )
                                .scaleEffect(cards[index].isLit ? 1.08 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: cards[index].isLit)
                                .onTapGesture {
                                    tapCard(index: index)
                                }
                        }
                    }
                    Spacer()
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.black, Color.cyan.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(.all, edges: .top)
            .onAppear {
                timeRemaining = roundLength
                gameStarted = true
            }
            .overlay(
                Group {
                    if showLevelFlash {
                        Text(flashMessage)
                            .font(.system(size: 44, weight: .heavy))
                            .foregroundColor(flashColor)
                            .shadow(color: flashColor.opacity(0.8), radius: 16)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: showLevelFlash)
                .allowsHitTesting(false)
            )

            .onReceive(countdownTimer) { _ in
                if gameStarted && timeRemaining > 0 {

                    let prevLevel = currentLevel
                    timeRemaining -= 1

                    if currentLevel != prevLevel {

                        for i in 0..<cards.count { cards[i].isLit = false }

                        cards = Array(repeating: Card(), count: currentLevel.cardCount)
                        lightAccumulator = 0

                        isTransitioning = true

                        flashMessage = currentLevel.name.uppercased() + "!"
                        flashColor = currentLevel.glowColor
                        showLevelFlash = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            showLevelFlash = false
                            isTransitioning = false
                        }
                    }
                }
            }
            .onReceive(lightTimer) { _ in
                if gameStarted && lives > 0 && !isTransitioning {
                    lightAccumulator += 0.4

                    if lightAccumulator >= currentLevel.litWindow {
                        lightAccumulator = 0

                        var anyMissed = false
                        for i in 0..<cards.count {
                            if cards[i].isLit { anyMissed = true }
                            cards[i].isLit = false
                        }

                        if anyMissed { lives -= 1 }

                        if lives > 0 && safeToLightCard {
                            let shuffledIndices = cards.indices.shuffled()
                            for i in 0..<min(currentLevel.litCount, shuffledIndices.count) {
                                cards[shuffledIndices[i]].isLit = true
                            }
                        }
                    }
                }
            }
        }
    }

    func tapCard(index: Int) {
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            lives -= 1
            for i in 0..<cards.count {
                cards[i].isLit = false
            }
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = roundLength
        gameStarted = true
        lives = 3
        lightAccumulator = 0
        cards = [Card(), Card(), Card()]
    }
}

#Preview {
    LightItUpView()
}
