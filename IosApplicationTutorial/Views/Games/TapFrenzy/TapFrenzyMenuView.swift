import SwiftUI

struct TapFrenzyMenuView: View {

    @State private var roundLength = 10
    private let orange = Color(red: 0.92, green: 0.26, blue: 0.35)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("tap_frenzy_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                VStack(spacing: 12) {
                    Image("tap_frenzy")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    VStack(spacing: 4) {
                        Text("Tap Frenzy")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("ACTION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                    }
                }
                
                Spacer()

                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 24)

                    VStack(spacing: 8) {
                        Text("HOW TO PLAY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1)

                        Text("Tap the giant colored button as fast as you can. Build combos to multiply your score. Avoid traps and watch for bonus bursts!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 24)
                }
                
                Spacer()

                NavigationLink(destination: TapFrenzyView(duration: 10)) {
                    PrimaryButton(
                        title: "START GAME",
                        icon:  "play.fill",
                        color: orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            SessionStore.shared.isTabBarHidden = true
        }
    }
}

#Preview {
    NavigationStack {
        TapFrenzyMenuView()
    }
}
