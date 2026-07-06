import SwiftUI

struct LightItUpMenuView: View {

    @AppStorage("roundLength") private var roundLength = 60

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
            """)
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.leading)

            // Round length picker (absorbed from SettingsView)
            VStack(alignment: .leading, spacing: 8) {
                Text("ROUND LENGTH")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.cyan)

                Picker("Round Length", selection: $roundLength) {
                    Text("30s").tag(30)
                    Text("60s").tag(60)
                    Text("90s").tag(90)
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .background(Color.white.opacity(0.07))
            .cornerRadius(12)

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
