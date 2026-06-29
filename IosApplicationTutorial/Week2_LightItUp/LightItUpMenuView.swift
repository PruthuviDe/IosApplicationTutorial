import SwiftUI

struct LightItUpMenuView: View {

    @State private var showSettings = false

    var body: some View {

        VStack(spacing: 24) {

            Spacer()

            Image(systemName: "lightbulb.fill")
                .font(.system(size: 64))
                .foregroundColor(.cyan)

            Text("Light It Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            
            Text("""
            How to Play

            • Tap the glowing card before it goes dark.
            • Earn points for every correct tap.
            • Missing a glowing card or tapping the wrong card costs a life.
            • Choose the round length in Settings before starting the game.
            """)
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.leading)

            Spacer()

            NavigationLink(destination: LightItUpView()) {
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan)
                    .cornerRadius(12)
            }

            Button("Settings") {
                showSettings = true
            }
            .font(.headline)
            .foregroundColor(.white.opacity(0.7))
            .padding(.vertical, 8)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color.cyan.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        LightItUpMenuView()
    }
}
