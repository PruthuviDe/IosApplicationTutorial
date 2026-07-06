import SwiftUI

struct HomeTab: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                VStack(spacing: 6) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.purple)

                    Text("PlayHub")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(.white)

                    Text("Choose your game")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 50)
                .padding(.bottom, 32)

                // Game tiles
                VStack(spacing: 14) {
                    GameTile(
                        mode: .tapFrenzy,
                        destination: AnyView(TapFrenzyView())
                    )
                    GameTile(
                        mode: .lightItUp,
                        destination: AnyView(LightItUpMenuView())
                    )
                    GameTile(
                        mode: .quizRush,
                        destination: AnyView(QuizMenuView())
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }
}

#Preview {
    HomeTab()
}
