import SwiftUI

struct LightItUpMenuView: View {

    @State private var isEndless   = true
    @State private var roundLength = 60

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

            VStack(spacing: 24) {

                Spacer()

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

                VStack(alignment: .leading, spacing: 12) {
                    Text("HOW TO PLAY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(cyan)
                        .tracking(1)

                    Text("Tap the glowing card before it goes dark. Tap the wrong card or miss it — lose a life. You have 3 lives.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(5)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("GAME MODE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(cyan)
                        .tracking(1)

                    Picker("Mode", selection: $isEndless) {
                        Text("⏱  Timed").tag(false)
                        Text("∞  Endless").tag(true)
                    }
                    .pickerStyle(.segmented)

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
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isEndless)

                Spacer()

                NavigationLink(destination: LightItUpView(roundLength: isEndless ? 0 : roundLength)) {
                    PrimaryButton(
                        title: "START GAME",
                        icon:  "play.fill",
                        color: cyan
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
}

#Preview {
    NavigationStack {
        LightItUpMenuView()
    }
}
