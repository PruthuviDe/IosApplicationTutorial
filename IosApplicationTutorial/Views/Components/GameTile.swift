import SwiftUI

struct GameTile: View {

    let mode: GameMode
    let destination: AnyView

    var highScoreKey: String {
        switch mode {
        case .tapFrenzy: return "tapFrenzyHighScore"
        case .lightItUp: return "lightItUpHighScore"
        case .quizRush:  return "quizRushHighScore"
        }
    }

    var highScore: Int {
        UserDefaults.standard.integer(forKey: highScoreKey)
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {

                Image(mode.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 52, height: 52)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(mode.accentColor.opacity(0.25), lineWidth: 1.5)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(mode.subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.25))

                    Text("Best: \(highScore)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(mode.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(mode.accentColor.opacity(0.10))
                        .cornerRadius(6)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GameTile(
        mode: .tapFrenzy,
        destination: AnyView(Text("Tap Frenzy View"))
    )
    .padding()
    .background(Color.black)
}
