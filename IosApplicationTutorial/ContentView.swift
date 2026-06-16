import SwiftUI
import Combine

struct ContentView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var highScore = 0
    @State private var comboMultiplier = 1
    @State private var lastTapTime = Date()
    @State private var buttonType = 0
    @State private var gameStarted = false

    @State private var scoreScale = 1.0
    @State private var timerPulse = false
    @State private var isNewHighScore = false
    @State private var glowExpand = false

    @State private var buttonOffsetX = 0.0
    @State private var buttonOffsetY = 0.0

    @State private var isBonusBurst = false

    // Countdown timer
    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // Changes button
    let colourTimer = Timer.publish(
        every: 2.5,
        on: .main,
        in: .common
    ).autoconnect()

    // Moving Target
    let moveTimer = Timer.publish(
        every: 2,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        if timeRemaining == 0 {


            VStack(spacing: 25) {

                Spacer()

                Text("GAME OVER")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.2), radius: 10)

                if isNewHighScore {
                    Label(
                        "NEW HIGH SCORE!",
                        systemImage: "crown.fill"
                    )
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 12)
                }

                Rectangle()
                    .frame(width: 100, height: 3)
                    .foregroundColor(.white.opacity(0.25))
                    .cornerRadius(2)
                    .padding(.vertical, 4)

                HStack(spacing: 12) {

                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 30))

                    Text("Score: \(score)")
                        .foregroundColor(.white)
                        .font(.system(size: 30, weight: .bold))
                }

                HStack(spacing: 12) {

                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 22))

                    Text("High Score: \(highScore)")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 22, weight: .semibold))
                }

                Button(action: {
                    restartGame()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("PLAY AGAIN")
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.85, green: 0.1, blue: 0.05))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.85, green: 0.1, blue: 0.05).opacity(0.6), radius: 12)
                }
                .padding(.top, 10)

                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.4, green: 0.0, blue: 0.05),
                        Color.orange.opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(.all, edges: .top)

        } else {

            VStack(spacing: 0) {

                Text("TAP FRENZY")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .padding(.bottom, 8)

                HStack {

                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("\(score)")
                            .fontWeight(.bold)
                            .scaleEffect(scoreScale)
                    }
                    .font(.title2)
                    .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(timeRemaining <= 3 ? .red : .white)
                        Text("\(timeRemaining)s")
                            .fontWeight(.bold)
                            .foregroundColor(timeRemaining <= 3 ? .red : .white)
                            .scaleEffect(timerPulse && timeRemaining <= 3 ? 1.3 : 1.0)
                    }
                    .font(.title2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                if comboMultiplier > 1 {
                    Label("x\(comboMultiplier) COMBO!", systemImage: "bolt.fill")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.yellow)
                        .padding(.bottom, 4)
                }

                if isBonusBurst {
                    Label("BONUS BURST! x2 POINTS!", systemImage: "flame.fill")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.yellow)
                        .padding(.bottom, 4)
                }

                if buttonType == 1 {
                    Label("BONUS: +3 per tap", systemImage: "star.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.green)
                        .padding(.bottom, 4)
                } else if buttonType == 2 {
                    Label("TRAP: -1 per tap", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.orange)
                        .padding(.bottom, 4)
                } else {
                    Label("NORMAL: +\(comboMultiplier) per tap", systemImage: "circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 4)
                }

                if !gameStarted {
                    Label("Tap to Begin", systemImage: "hand.tap.fill")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 4)
                }

                Spacer()

                Button(action: {
                    handleTap()
                }) {
                    Text("TAP!!")
                        .font(.system(size: 46, weight: .black))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 220)
                    .background(
                        buttonType == 1 ? Color.green :
                        buttonType == 2 ? Color.gray :
                        Color(red: 0.85, green: 0.1, blue: 0.05)
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                buttonType == 1 ? Color.green.opacity(0.3) :
                                buttonType == 2 ? Color.gray.opacity(0.3) :
                                Color.orange.opacity(0.4),
                                lineWidth: 3
                            )
                            .scaleEffect(glowExpand ? 1.4 : 1.05)
                            .opacity(glowExpand ? 0.0 : 0.8)
                    )
                    .shadow(
                        color:
                            buttonType == 1 ? .green :
                            buttonType == 2 ? .gray :
                            Color(red: 0.85, green: 0.1, blue: 0.05),
                        radius: 20
                    )
                }
                .offset(x: buttonOffsetX, y: buttonOffsetY)
                .scaleEffect(0.4 + (Double(timeRemaining) / 10.0 * 0.6))
                .animation(.easeInOut(duration: 0.8), value: timeRemaining)
                .onAppear {
                    withAnimation(
                        .easeOut(duration: 1.8)
                        .repeatForever(autoreverses: false)
                    ) {
                        glowExpand = true
                    }
                }

                Spacer()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.4, green: 0.0, blue: 0.05),
                        Color.orange.opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(.all, edges: .top)

            .onReceive(timer) { _ in

                if gameStarted && timeRemaining > 0 {
                    timeRemaining -= 1

                    if timeRemaining == 7 {
                        isBonusBurst = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isBonusBurst = false
                        }
                    }

                    if timeRemaining <= 3 && !timerPulse {
                        withAnimation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            timerPulse = true
                        }
                    }
                }

                if timeRemaining == 0 {
                    if score > highScore {
                        highScore = score
                        isNewHighScore = true
                    } else {
                        isNewHighScore = false
                    }
                }
            }

            .onReceive(colourTimer) { _ in

                if gameStarted {
                    buttonType = Int.random(in: 0...2)
                }
            }

            .onReceive(moveTimer) { _ in

                if gameStarted {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        buttonOffsetX = Double.random(in: -80...80)
                        buttonOffsetY = Double.random(in: -150...150)
                    }
                }
            }
        }
    }

    func handleTap() {

        if !gameStarted {
            gameStarted = true
        }

        let now = Date()


        if now.timeIntervalSince(lastTapTime) < 0.5 {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }

        lastTapTime = now

        if buttonType == 1 {

            score += isBonusBurst ? 6 : 3

        } else if buttonType == 2 {

            score = max(0, score - 1)

            comboMultiplier = 1

        } else {

            score += isBonusBurst ? comboMultiplier * 2 : comboMultiplier
        }

        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            scoreScale = 1.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                scoreScale = 1.0
            }
        }
    }


    func restartGame() {

        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        lastTapTime = Date()
        buttonType = 0
        gameStarted = false

        scoreScale = 1.0
        timerPulse = false
        isNewHighScore = false
        glowExpand = false
        buttonOffsetX = 0.0
        buttonOffsetY = 0.0
        isBonusBurst = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(
                .easeOut(duration: 1.8)
                .repeatForever(autoreverses: false)
            ) {
                glowExpand = true
            }
        }
    }
}

#Preview {
    ContentView()
}

