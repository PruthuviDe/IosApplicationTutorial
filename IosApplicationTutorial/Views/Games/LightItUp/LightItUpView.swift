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
        case .L1: return Color(red: 0.20, green: 0.83, blue: 0.95)
        case .L2: return Color(red: 0.20, green: 0.83, blue: 0.52)
        case .L3: return Color(red: 0.95, green: 0.60, blue: 0.20)
        case .L4: return Color(red: 0.92, green: 0.26, blue: 0.35)
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

        Group {

            if timeRemaining == 0 || lives == 0 {

                VStack(spacing: 24) {

                    Spacer()

                    Text("GAME OVER")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(2)

                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("LAMPS LIT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                    }

                    if lives == 0 {
                        Text("No lives left!")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.92, green: 0.26, blue: 0.35))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.92, green: 0.26, blue: 0.35).opacity(0.1))
                            .cornerRadius(12)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.white.opacity(0.4))
                            Text("Best: \(highScore)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }

                    Spacer()

                    VStack(spacing: 14) {
                        ShareLink(item: "I just scored \(score) on Light It Up in PlayHub — beat that! 🎮") {
                            Label("Share Score", systemImage: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.95))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.20, green: 0.83, blue: 0.95).opacity(0.12))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 0.20, green: 0.83, blue: 0.95).opacity(0.30), lineWidth: 1)
                                )
                        }

                        Button(action: { restartGame() }) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.20, green: 0.83, blue: 0.95))
                                .cornerRadius(24)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.02, green: 0.07, blue: 0.08), Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(.all, edges: .top)
                .onAppear {
                    if score > highScore {
                        highScore = score
                    }
                    let loc = LocationService.shared.coordinate
                    SessionStore.shared.save(session: GameSession(
                        mode: .lightItUp,
                        score: score,
                        latitude: loc.latitude,
                        longitude: loc.longitude
                    ))
                }

            } else {

                ZStack {

                    RadialGradient(
                        colors: [currentLevel.glowColor.opacity(0.20), Color.black],
                        center: .center,
                        startRadius: 10,
                        endRadius: 360
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: currentLevel)

                    VStack(spacing: 20) {

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SCORE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("\(score)")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 80, alignment: .leading)

                            Spacer()

                            Text(currentLevel.name.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(currentLevel.glowColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(currentLevel.glowColor.opacity(0.12))
                                .cornerRadius(8)
                                .padding(.top, 4)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("TIME")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("\(timeRemaining)s")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(timeRemaining <= 5 ? Color(red: 0.92, green: 0.26, blue: 0.35) : .white)
                                    .scaleEffect(timeRemaining <= 5 ? 1.25 : 1.0)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.5), value: timeRemaining)
                            }
                            .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .foregroundColor(index < lives ? Color(red: 0.92, green: 0.26, blue: 0.35) : .white.opacity(0.2))
                            }
                        }
                        .font(.system(size: 18))
                        .padding(.top, 4)

                        Spacer()

                        HStack {
                            Spacer()
                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                ForEach(0..<cards.count, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(cards[index].isLit ? currentLevel.glowColor : Color.white.opacity(0.06))
                                        .frame(width: 95, height: 95)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(cards[index].isLit ? currentLevel.glowColor : Color.white.opacity(0.12), lineWidth: 1.5)
                                        )
                                        .shadow(color: cards[index].isLit ? currentLevel.glowColor.opacity(0.45) : .clear, radius: 12)
                                        .scaleEffect(cards[index].isLit ? 1.06 : 1.0)
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.07, green: 0.08, blue: 0.10), Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(.all)
                )
                .onAppear {
                    timeRemaining = roundLength
                    gameStarted = true
                }
                .overlay(
                    Group {
                        if showLevelFlash {
                            Text(flashMessage)
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundColor(flashColor)
                                .shadow(color: flashColor.opacity(0.6), radius: 12)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut(duration: 0.35), value: showLevelFlash)
                    .allowsHitTesting(false)
                )

                .onReceive(countdownTimer) { _ in
                    guard gameStarted && timeRemaining > 0 else { return }

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
                .onReceive(lightTimer) { _ in
                    guard gameStarted && lives > 0 && !isTransitioning else { return }
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
        .toolbar(.hidden, for: .tabBar)
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
