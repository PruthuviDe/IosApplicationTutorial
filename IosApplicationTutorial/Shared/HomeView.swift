import SwiftUI

struct HomeView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 24) {

                Text("Game Collection")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Select a game")
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                NavigationLink(destination: ContentView()) {
                    Text("Tap Frenzy")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }

                NavigationLink(destination: LightItUpMenuView()) {
                    Text("Light It Up")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(12)
                }

                NavigationLink(destination: QuizView()) {
                    Text("Quiz Rush")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: HighScoreView()) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}
#Preview {
    HomeView()
}
