import SwiftUI

struct LightItUpMenuView: View {

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [Color(red: 0.20, green: 0.83, blue: 0.95).opacity(0.18), Color.black],
                center: .top,
                startRadius: 10,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                Image("light_it_up")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(18)
                    .shadow(color: Color(red: 0.20, green: 0.83, blue: 0.95).opacity(0.35), radius: 12)

                Text("Light It Up")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(0.5)

                // How to play
                VStack(alignment: .leading, spacing: 12) {
                    Text("HOW TO PLAY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.95))
                        .tracking(1)

                    Text("• Tap the glowing card before it goes dark.\n• Missing or tapping the wrong card costs a life.\n• You have 3 lives — survive as long as you can!")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(6)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

                // Progressive difficulty info
                VStack(alignment: .leading, spacing: 12) {
                    Text("PROGRESSIVE DIFFICULTY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.95))
                        .tracking(1)

                    VStack(alignment: .leading, spacing: 6) {
                        diffRow(score: "Score 0+",  desc: "Tap the glowing card")
                        diffRow(score: "Score 10+", desc: "Multiple colours — tap the right one")
                        diffRow(score: "30+",       desc: "Sequence mode — tap in order 🟢→🔵→🟠")
                        diffRow(score: "Higher…",   desc: "More cards, faster windows, no ceiling")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

                Spacer()

                NavigationLink(destination: LightItUpView()) {
                    PrimaryButton(
                        title: "START GAME",
                        icon:  "play.fill",
                        color: Color(red: 0.20, green: 0.83, blue: 0.95)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 20)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.08, blue: 0.10), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .toolbar(.hidden, for: .tabBar)
    }

    private func diffRow(score: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(score)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.95))
                .frame(width: 68, alignment: .leading)
            Text(desc)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpMenuView()
    }
}
