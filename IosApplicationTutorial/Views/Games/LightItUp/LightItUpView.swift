import SwiftUI
import Combine

struct LightItUpView: View {

    @StateObject private var vm = LightItUpViewModel()

    var body: some View {
        Group {
            if vm.isGameOver {
                ResultView(
                    mode:      .lightItUp,
                    score:     vm.score,
                    onRestart: { vm.restart() }
                )
                .onAppear { vm.saveSession() }

            } else {
                gameView
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Game Screen

    private var gameView: some View {
        ZStack {
            // Background: ambient glow shifts colour with difficulty
            RadialGradient(
                colors: [vm.difficulty.accentColor.opacity(0.20), Color.black],
                center: .center,
                startRadius: 10,
                endRadius: 360
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: vm.score / 5)

            LinearGradient(
                colors: [Color(red: 0.07, green: 0.08, blue: 0.10), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(0.75)

            VStack(spacing: 16) {
                hud
                livesRow
                Spacer()
                hintBar
                cardGrid
                Spacer()
            }
        }
        // Red flash when the player taps wrong or misses a card
        .overlay(
            Color.red
                .opacity(vm.wrongFlash ? 0.28 : 0.00)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.15), value: vm.wrongFlash)
        )
        // Score milestone banner ("Lv.2!", "Lv.3!"…)
        .overlay(
            Group {
                if vm.showBanner {
                    Text(vm.bannerMessage)
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundColor(vm.bannerColor)
                        .shadow(color: vm.bannerColor.opacity(0.6), radius: 14)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: vm.showBanner)
            .allowsHitTesting(false)
        )
        .onAppear  { vm.startGame() }
        .onReceive(vm.lightTimer) { _ in vm.lightTick() }
    }

    // MARK: - HUD (Score | Level badge | Speed)

    private var hud: some View {
        HStack(alignment: .top) {
            // Score
            VStack(alignment: .leading, spacing: 4) {
                Text("SCORE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                Text("\(vm.score)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 80, alignment: .leading)

            Spacer()

            // Difficulty badge — advances automatically with score
            Text("Lv.\(vm.score / 5 + 1)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(vm.difficulty.accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(vm.difficulty.accentColor.opacity(0.12))
                .cornerRadius(8)
                .padding(.top, 4)
                .animation(.easeInOut(duration: 0.3), value: vm.score / 5)

            Spacer()

            // Speed indicator so the player can see it getting faster
            VStack(alignment: .trailing, spacing: 4) {
                Text("SPEED")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                Text("\(String(format: "%.1f", vm.difficulty.litWindow))s")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Lives Row (hearts pulse on wrong tap)

    private var livesRow: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < vm.lives ? "heart.fill" : "heart")
                    .foregroundColor(index < vm.lives
                                     ? Color(red: 0.92, green: 0.26, blue: 0.35)
                                     : .white.opacity(0.2))
            }
        }
        .font(.system(size: 18))
        .scaleEffect(vm.wrongFlash ? 1.2 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.45), value: vm.wrongFlash)
    }

    // MARK: - Hint Bar

    /// Shows nothing in simple mode (score < 10).
    /// Shows the target colour in colour mode (score 10–29).
    /// Shows the full tap sequence with the current step highlighted (score 30+).
    @ViewBuilder
    private var hintBar: some View {
        let diff = vm.difficulty

        if diff.sequenceLength > 0 && !vm.sequenceTarget.isEmpty {
            // Sequence hint: e.g.  "Tap in order:  🟢 → 🟠 → 🔵"
            HStack(spacing: 6) {
                Text("Tap in order:")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))

                ForEach(Array(vm.sequenceTarget.enumerated()), id: \.offset) { idx, color in
                    Text(color.emoji)
                        .font(.system(size: idx == vm.sequenceStep ? 26 : 20))
                        .opacity(idx < vm.sequenceStep ? 0.25 : 1.0)
                        .scaleEffect(idx == vm.sequenceStep ? 1.25 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6),
                                   value: vm.sequenceStep)

                    if idx < vm.sequenceTarget.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 4)

        } else if diff.colorCount > 1 {
            // Single-colour hint: e.g.  "Tap: 🟢 Green"
            HStack(spacing: 6) {
                Text("Tap:")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                Text(vm.targetColor.emoji)
                    .font(.system(size: 26))
                Text(vm.targetColor.displayName)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(vm.targetColor.uiColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(vm.targetColor.uiColor.opacity(0.10))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            .animation(.easeInOut(duration: 0.2), value: vm.targetColor)
        }
    }

    // MARK: - Card Grid

    private var cardGrid: some View {
        // Card height shrinks slightly for larger grids so everything fits on screen
        let cardHeight: CGFloat = vm.difficulty.cardCount <= 6 ? 90 : 72

        return LazyVGrid(columns: vm.gridColumns, spacing: 12) {
            ForEach(0..<vm.cards.count, id: \.self) { index in
                let card = vm.cards[index]
                let litColor = card.color.uiColor

                RoundedRectangle(cornerRadius: 16)
                    .fill(card.isLit ? litColor : Color.white.opacity(0.06))
                    .frame(height: cardHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                card.isLit ? litColor : Color.white.opacity(0.12),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: card.isLit ? litColor.opacity(0.55) : .clear,
                        radius: 14
                    )
                    .scaleEffect(card.isLit ? 1.06 : 1.0)
                    .animation(.easeInOut(duration: 0.18), value: card.isLit)
                    .onTapGesture { vm.tapCard(index: index) }
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    LightItUpView()
}
