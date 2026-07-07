import SwiftUI
import Combine

struct TapFrenzyView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    @State private var comboMultiplier = 1
    @State private var lastTapTime = Date()
    @State private var buttonType = 0       // 0 = normal, 1 = bonus, 2 = trap
    @State private var gameStarted = false
    @State private var isNewHighScore = false

    @State private var buttonOffsetX = 0.0
    @State private var buttonOffsetY = 0.0

    @State private var isBonusBurst = false
    @State private var bonusBurstStart = 5

    @State private var buttonPressed = false

    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var activeColor: Color {
        if buttonType == 1 { return Color(red: 0.20, green: 0.83, blue: 0.52) }
        if buttonType == 2 { return Color(red: 0.65, green: 0.68, blue: 0.80) }
        return Color(red: 0.92, green: 0.26, blue: 0.35)
    }

    var body: some View {

        Group {

            if timeRemaining == 0 {
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
                        Text("POINTS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                    }

                    if isNewHighScore {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("NEW HIGH SCORE!")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.yellow.opacity(0.1))
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
                        ShareLink(item: "I just scored \(score) on Tap Frenzy in PlayHub — beat that! 🎮") {
                            Label("Share Score", systemImage: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.92, green: 0.26, blue: 0.35))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.92, green: 0.26, blue: 0.35).opacity(0.12))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 0.92, green: 0.26, blue: 0.35).opacity(0.30), lineWidth: 1)
                                )
                        }

                        Button(action: { restartGame() }) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.92, green: 0.26, blue: 0.35))
                                .cornerRadius(24)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.02, blue: 0.02), Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(.all, edges: .top)

            } else {
                ZStack {
                    RadialGradient(
                        colors: [activeColor.opacity(0.30), Color.black],
                        center: .center,
                        startRadius: 10,
                        endRadius: 360
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: buttonType)

                    VStack(spacing: 20) {

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SCORE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("\(score)")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("TIME")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("\(timeRemaining)s")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(timeRemaining <= 3 ? Color(red: 0.92, green: 0.26, blue: 0.35) : .white)
                                    .scaleEffect(timeRemaining <= 3 ? 1.25 : 1.0)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        VStack(spacing: 6) {
                            if comboMultiplier > 1 {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 14))
                                    Text("\(comboMultiplier)x Combo Active")
                                }
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.3), radius: 8)
                            }
                            
                            if isBonusBurst {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12))
                                    Text("Double Points Active")
                                }
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.52))
                                .shadow(color: Color(red: 0.20, green: 0.83, blue: 0.52).opacity(0.3), radius: 8)
                            }
                        }
                        .frame(height: 55)

                        Spacer()

                        Button(action: { handleTap() }) {
                            ZStack {
                                Circle()
                                    .fill(activeColor)
                                    .shadow(color: activeColor.opacity(0.4), radius: 20)

                                VStack(spacing: 2) {
                                    if !gameStarted {
                                        Text("START")
                                            .font(.system(size: 26, weight: .bold, design: .rounded))
                                    } else {
                                        Text(buttonType == 1 ? "BONUS" : buttonType == 2 ? "TRAP" : "NORMAL")
                                            .font(.system(size: 24, weight: .black, design: .rounded))
                                        
                                        Text(buttonType == 1 ? "+3" : buttonType == 2 ? "-1" : "+\(comboMultiplier)")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .foregroundColor(.white)
                            }
                            .frame(width: 220, height: 220)
                        }
                        .scaleEffect(buttonPressed ? 0.88 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: buttonPressed)
                        .offset(x: buttonOffsetX, y: buttonOffsetY)
                        .scaleEffect(0.6 + (Double(timeRemaining) / 10.0 * 0.4))
                        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: timeRemaining)

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

                .onReceive(timer) { _ in
                    guard gameStarted && timeRemaining > 0 else { return }

                    timeRemaining -= 1

                    buttonType = Int.random(in: 0...2)
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
                        if score > highScore {
                            highScore = score
                            isNewHighScore = true
                        } else {
                            isNewHighScore = false
                        }
                        let loc = LocationService.shared.coordinate
                        SessionStore.shared.save(session: GameSession(
                            mode: .tapFrenzy,
                            score: score,
                            latitude: loc.latitude,
                            longitude: loc.longitude
                        ))
                    }
                }
            }

        }
        .toolbar(.hidden, for: .tabBar)
    }

    func handleTap() {
        if !gameStarted {
            gameStarted = true
            bonusBurstStart = Int.random(in: 4...8)
        }
        buttonPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            buttonPressed = false
        }

        let now = Date()
        if now.timeIntervalSince(lastTapTime) < 0.8 {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }
        lastTapTime = now

        var gained = 0
        if buttonType == 1 {
            gained = (isBonusBurst ? 6 : 3) * comboMultiplier
            score += gained
        } else if buttonType == 2 {
            gained = -1 * comboMultiplier
            score = max(0, score + gained)
            comboMultiplier = 1
        } else {
            gained = isBonusBurst ? comboMultiplier * 2 : comboMultiplier
            score += gained
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        lastTapTime = Date()
        buttonType = 0
        gameStarted = false
        isNewHighScore = false
        isBonusBurst = false
        bonusBurstStart = 5
        buttonOffsetX = 0.0
        buttonOffsetY = 0.0
        buttonPressed = false
    }
}

#Preview {
    TapFrenzyView()
}
