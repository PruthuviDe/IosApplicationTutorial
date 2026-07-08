import SwiftUI

struct ResultView: View {

    let mode:      GameMode
    let score:     Int
    let onRestart: () -> Void

    @ObservedObject private var store = SessionStore.shared
    @State private var isNewBest = false

    var currentBest: Int { store.highScore(for: mode) }

    var body: some View {
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

            if isNewBest {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("NEW HIGH SCORE!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.10))
                .cornerRadius(12)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.white.opacity(0.4))
                    Text("Best: \(currentBest)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            VStack(spacing: 20) {
                Button(action: onRestart) {
                    PrimaryButton(
                        title: "PLAY AGAIN",
                        icon: "arrow.clockwise",
                        color: mode.accentColor
                    )
                }
                .buttonStyle(PlainButtonStyle())

                ShareLink(item: "I just scored \(score) on \(mode.rawValue) in GameVault — beat that! 🎮") {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share Score")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(mode.accentColor.opacity(0.90))
                    .padding(.vertical, 8)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [mode.backgroundTopColor, Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(.all)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            isNewBest = score > store.highScore(for: mode)
        }
    }
}

#Preview {
    ResultView(
        mode:      .tapFrenzy,
        score:     42,
        onRestart: {}
    )
}
