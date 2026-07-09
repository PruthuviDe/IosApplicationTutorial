import SwiftUI

struct LightItUpMenuView: View {

    // Mode selection: Endless (0) or Timed (30/60/90)
    @State private var isEndless    = true
    @State private var roundLength  = 60

    private let cyan = Color(red: 0.20, green: 0.83, blue: 0.95)

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [cyan.opacity(0.18), Color.black],
                center: .top,
                startRadius: 10,
                endRadius: 400
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    Spacer().frame(height: 16)

                    // Game icon + title
                    Image("light_it_up")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .shadow(color: cyan.opacity(0.35), radius: 12)

                    Text("Light It Up")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(0.5)

                    // How to play
                    cardBox(title: "HOW TO PLAY") {
                        Text("• Tap the glowing card before it goes dark.\n• Missing or tapping the wrong card costs a life.\n• You have 3 lives — survive as long as you can!")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(6)
                    }

                    // Game mode picker
                    cardBox(title: "GAME MODE") {
                        Picker("Mode", selection: $isEndless) {
                            Text("⏱  Timed").tag(false)
                            Text("∞  Endless").tag(true)
                        }
                        .pickerStyle(.segmented)

                        // Round length only shown in Timed mode
                        if !isEndless {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ROUND LENGTH")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(cyan)
                                    .tracking(1)

                                Picker("Round Length", selection: $roundLength) {
                                    Text("30 s").tag(30)
                                    Text("60 s").tag(60)
                                    Text("90 s").tag(90)
                                }
                                .pickerStyle(.segmented)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isEndless)

                    // Progressive difficulty info
                    cardBox(title: "PROGRESSIVE DIFFICULTY") {
                        VStack(alignment: .leading, spacing: 6) {
                            diffRow(score: "Score 0+",  desc: "Tap the glowing card")
                            diffRow(score: "Score 10+", desc: "Multiple colours — tap the right one")
                            diffRow(score: "Score 30+", desc: "Sequence mode — tap in order 🟢→🔵→🟠")
                            diffRow(score: "Higher…",   desc: "More cards, faster windows, no ceiling")
                        }
                    }

                    // START button — passes the chosen round length (0 if Endless)
                    NavigationLink(destination: LightItUpView(roundLength: isEndless ? 0 : roundLength)) {
                        PrimaryButton(
                            title: "START GAME",
                            icon:  "play.fill",
                            color: cyan
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 4)

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 28)
            }
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

    // MARK: - Helpers

    @ViewBuilder
    private func cardBox<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(cyan)
                .tracking(1)
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func diffRow(score: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(score)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(cyan)
                .frame(width: 72, alignment: .leading)
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
