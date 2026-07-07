import SwiftUI

// MARK: - ResultView
/// A shared game-over result screen used across all three game modes.
/// Accepts the mode, score, and an action to restart the game.
struct ResultView: View {

    let mode:       GameMode
    let score:      Int
    let highScore:  Int
    let isNewBest:  Bool
    let onRestart:  () -> Void

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // Game over header
            Text("GAME OVER")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)

            // Score display
            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("POINTS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1)
            }

            // New high score / best badge
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
                    Text("Best: \(highScore)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            // Action buttons
            VStack(spacing: 14) {
                ShareLink(item: "I just scored \(score) on \(mode.rawValue) in PlayHub — beat that! 🎮") {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(mode.accentColor)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(mode.accentColor.opacity(0.12))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(mode.accentColor.opacity(0.30), lineWidth: 1)
                        )
                }

                Button(action: onRestart) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(mode.accentColor)
                        .cornerRadius(24)
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
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    ResultView(
        mode: .tapFrenzy,
        score: 42,
        highScore: 50,
        isNewBest: false,
        onRestart: {}
    )
}
