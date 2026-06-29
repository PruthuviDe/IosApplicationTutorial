import SwiftUI

struct HighScoreView: View {

    @AppStorage("tapFrenzyHighScore") private var tapFrenzyScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpScore = 0
    @AppStorage("quizRushHighScore") private var quizRushScore = 0

    var body: some View {

        VStack(spacing: 32) {

            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("High Scores")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            scoreCard(
                icon: "hand.tap.fill",
                iconColor: .red,
                gameName: "Tap Frenzy",
                score: tapFrenzyScore
            )

            scoreCard(
                icon: "lightbulb.fill",
                iconColor: .cyan,
                gameName: "Light It Up",
                score: lightItUpScore
            )

            scoreCard(
                icon: "questionmark.circle.fill",
                iconColor: .purple,
                gameName: "Quiz Rush",
                score: quizRushScore
            )

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    func scoreCard(icon: String, iconColor: Color, gameName: String, score: Int) -> some View {
        HStack(spacing: 16) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 36)

            Text(gameName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            Text("\(score) pts")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(score > 0 ? .yellow : .white.opacity(0.4))
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .cornerRadius(12)
    }
}

#Preview {
    HighScoreView()
}
