import SwiftUI
import Combine

struct LightItUpView: View {

    @StateObject private var vm: LightItUpViewModel

    init(roundLength: Int = 0) {
        _vm = StateObject(wrappedValue: LightItUpViewModel(roundLength: roundLength))
    }

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
        .onAppear {
            SessionStore.shared.isTabBarHidden = true
        }
    }

    private var gameView: some View {
        ZStack {
            RadialGradient(
                colors: [vm.levelAccentColor.opacity(0.20), Color.black],
                center: .center,
                startRadius: 10,
                endRadius: 360
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: vm.levelNumber)

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
        .overlay(
            Color.red
                .opacity(vm.wrongFlash ? 0.28 : 0.00)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.15), value: vm.wrongFlash)
        )
        .overlay(
            Group {
                if vm.showBanner {
                    Text(vm.bannerMessage.uppercased())
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(vm.bannerColor)
                        .tracking(3)
                        .shadow(color: .black.opacity(0.85), radius: 4, x: 0, y: 2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: vm.showBanner)
            .allowsHitTesting(false)
        )
        .onAppear  { vm.startGame() }
        .onReceive(vm.lightTimer)     { _ in vm.lightTick() }
        .onReceive(vm.countdownTimer) { _ in vm.countdownTick() }
    }

    private var hud: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SCORE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                Text("\(vm.score)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 100, alignment: .leading)

            Spacer()

            VStack(alignment: .center, spacing: 4) {
                Text("LEVEL")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                Text("\(vm.levelNumber)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(vm.levelAccentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .animation(.easeInOut(duration: 0.3), value: vm.levelNumber)

            Spacer()

            if vm.roundLength > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("TIME")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text("\(vm.timeRemaining)s")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(vm.timeRemaining <= 5
                                         ? Color(red: 0.92, green: 0.26, blue: 0.35)
                                         : .white)
                        .scaleEffect(vm.timeRemaining <= 5 ? 1.2 : 1.0)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5),
                                   value: vm.timeRemaining)
                }
                .frame(width: 100, alignment: .trailing)
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SPEED")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text("\(String(format: "%.1f", vm.difficulty.litWindow))s")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(width: 100, alignment: .trailing)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

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

    @ViewBuilder
    private var hintBar: some View {
        let diff = vm.difficulty

        if diff.sequenceLength > 0 && !vm.sequenceTarget.isEmpty {
            HStack(spacing: 8) {
                Text("TAP IN ORDER:")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1.5)

                HStack(spacing: 8) {
                    ForEach(Array(vm.sequenceTarget.enumerated()), id: \.offset) { idx, color in
                        let isCurrent = idx == vm.sequenceStep
                        let isDone    = idx < vm.sequenceStep
                        let dotSize: CGFloat = isCurrent ? 20 : 14

                        Circle()
                            .fill(isDone ? Color.white.opacity(0.15) : color.uiColor)
                            .frame(width: dotSize, height: dotSize)
                            .overlay(
                                Circle()
                                    .stroke(isCurrent ? color.uiColor : Color.clear, lineWidth: 2)
                                    .scaleEffect(1.3)
                                    .opacity(isCurrent ? 0.5 : 0)
                            )
                    }
                }
            }
            .padding(.bottom, 8)

        } else if diff.colorCount > 1 {
            HStack(spacing: 4) {
                Text("TAP THE")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1.5)
                Text(vm.targetColor.displayName.uppercased())
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(vm.targetColor.uiColor)
                    .tracking(1.5)
                Text("CARD")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1.5)
            }
            .padding(.bottom, 8)
            .animation(.easeInOut(duration: 0.2), value: vm.targetColor)
        }
    }

    private var cardGrid: some View {
        LazyVGrid(columns: vm.gridColumns, spacing: 12) {
            ForEach(0..<vm.cards.count, id: \.self) { index in
                let card     = vm.cards[index]
                let litColor = card.color.uiColor

                RoundedRectangle(cornerRadius: 16)
                    .fill(card.isLit ? litColor : Color.white.opacity(0.06))
                    .frame(width: 82, height: 82) 
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
