import SwiftUI
import Combine

struct TapFrenzyView: View {

    @StateObject private var vm: TapFrenzyViewModel

    init(duration: Int = 10) {
        _vm = StateObject(wrappedValue: TapFrenzyViewModel(duration: duration))
    }

    var body: some View {
        Group {
            if vm.timeRemaining == 0 {
                ResultView(
                    mode:      .tapFrenzy,
                    score:     vm.score,
                    onRestart: { vm.restart() }
                )
                .onAppear { vm.saveSession() }
                .toolbar(.hidden, for: .tabBar)
            } else {
                ZStack {
                    RadialGradient(
                        colors: [vm.buttonType.color.opacity(0.30), Color.black],
                        center: .center,
                        startRadius: 10,
                        endRadius: 360
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: vm.buttonType)

                    VStack(spacing: 20) {

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SCORE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("\(vm.score)")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("TIME")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("\(vm.timeRemaining)s")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(vm.timeRemaining <= 3
                                                     ? Color(red: 0.92, green: 0.26, blue: 0.35)
                                                     : .white)
                                    .scaleEffect(vm.timeRemaining <= 3 ? 1.25 : 1.0)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        VStack(spacing: 8) {
                            if vm.comboMultiplier > 1 {
                                Text("COMBO X\(vm.comboMultiplier)")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(.yellow)
                                    .tracking(2)
                            }
                            if vm.isBonusBurst {
                                Text("DOUBLE POINTS")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.52))
                                    .tracking(2)
                            }
                        }
                        .frame(height: 40)

                        Spacer()

                        Button(action: { vm.handleTap() }) {
                            ZStack {
                                Circle()
                                    .fill(vm.buttonType.color)
                                    .shadow(color: vm.buttonType.color.opacity(0.4), radius: 20)

                                VStack(spacing: 2) {
                                    if !vm.gameStarted {
                                        Text("START")
                                            .font(.system(size: 26, weight: .bold, design: .rounded))
                                    } else {
                                        Text(vm.buttonType.label)
                                            .font(.system(size: 24, weight: .black, design: .rounded))
                                        Text(vm.buttonType.scoreLabel(combo: vm.comboMultiplier))
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .foregroundColor(.white)
                            }
                            .frame(width: 220, height: 220)
                        }
                        .scaleEffect(vm.buttonPressed ? 0.88 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: vm.buttonPressed)
                        .offset(x: vm.buttonOffsetX, y: vm.buttonOffsetY)
                        .scaleEffect(0.6 + (Double(vm.timeRemaining) / Double(vm.initialDuration) * 0.4))
                        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: vm.timeRemaining)

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
                .onReceive(vm.timer) { _ in vm.tick() }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            SessionStore.shared.isTabBarHidden = true
        }
    }
}

#Preview {
    TapFrenzyView()
}
