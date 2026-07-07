import SwiftUI

struct HomeTab: View {

    @AppStorage("playerName") private var playerName = "Player One"

    var body: some View {

        NavigationStack {

            ZStack {
                RadialGradient(
                    colors: [Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.24), Color.black],
                    center: .top,
                    startRadius: 10,
                    endRadius: 400
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.40))

                            Text(playerName)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.20),
                                                 Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 46, height: 46)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.35), lineWidth: 1.5)
                                )

                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.65, green: 0.35, blue: 0.95))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 28)

                    HStack {
                        Text("SELECT GAME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1.5)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            GameTile(mode: .tapFrenzy, destination: TapFrenzyView())
                            GameTile(mode: .lightItUp, destination: LightItUpMenuView())
                            GameTile(mode: .quizRush,  destination: QuizMenuView())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }

                    Spacer()
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.09, blue: 0.14), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

#Preview {
    HomeTab()
}
