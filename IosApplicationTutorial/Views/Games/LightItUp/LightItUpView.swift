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
                ZStack {
                    RadialGradient(
                        colors: [vm.currentLevel.glowColor.opacity(0.20), Color.black],
                        center: .center,
                        startRadius: 10,
                        endRadius: 360
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: vm.currentLevel)

                    VStack(spacing: 20) {

                        HStack(alignment: .top) {
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

                            Text(vm.currentLevel.name.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(vm.currentLevel.glowColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(vm.currentLevel.glowColor.opacity(0.12))
                                .cornerRadius(8)
                                .padding(.top, 4)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("TIME")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("\(vm.timeRemaining)s")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(vm.timeRemaining <= 5
                                                     ? Color(red: 0.92, green: 0.26, blue: 0.35)
                                                     : .white)
                                    .scaleEffect(vm.timeRemaining <= 5 ? 1.25 : 1.0)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.5), value: vm.timeRemaining)
                            }
                            .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < vm.lives ? "heart.fill" : "heart")
                                    .foregroundColor(index < vm.lives
                                                     ? Color(red: 0.92, green: 0.26, blue: 0.35)
                                                     : .white.opacity(0.2))
                            }
                        }
                        .font(.system(size: 18))
                        .padding(.top, 4)

                        Spacer()

                        HStack {
                            Spacer()
                            LazyVGrid(columns: vm.gridColumns, spacing: 16) {
                                ForEach(0..<vm.cards.count, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(vm.cards[index].isLit
                                              ? vm.currentLevel.glowColor
                                              : Color.white.opacity(0.06))
                                        .frame(width: 95, height: 95)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(vm.cards[index].isLit
                                                        ? vm.currentLevel.glowColor
                                                        : Color.white.opacity(0.12),
                                                        lineWidth: 1.5)
                                        )
                                        .shadow(
                                            color: vm.cards[index].isLit
                                                ? vm.currentLevel.glowColor.opacity(0.45)
                                                : .clear,
                                            radius: 12
                                        )
                                        .scaleEffect(vm.cards[index].isLit ? 1.06 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: vm.cards[index].isLit)
                                        .onTapGesture { vm.tapCard(index: index) }
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
                .overlay(
                    Group {
                        if vm.showLevelFlash {
                            Text(vm.flashMessage)
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundColor(vm.flashColor)
                                .shadow(color: vm.flashColor.opacity(0.6), radius: 12)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut(duration: 0.35), value: vm.showLevelFlash)
                    .allowsHitTesting(false)
                )
                .onAppear  { vm.startGame() }
                .onReceive(vm.countdownTimer) { _ in vm.countdownTick() }
                .onReceive(vm.lightTimer)     { _ in vm.lightTick() }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    LightItUpView()
}
