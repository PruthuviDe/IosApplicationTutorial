import SwiftUI

struct LightItUpMenuView: View {

    @State private var isEndless   = true
    @State private var roundLength = 60

    private let cyan = Color(red: 0.20, green: 0.83, blue: 0.95)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("light_it_up_bg")
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
                    .frame(height: 50)

                VStack(spacing: 12) {
                    Image("light_it_up")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    VStack(spacing: 4) {
                        Text("Light It Up")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("PUZZLE")
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

                        Text("Tap the glowing card before it goes dark. Tap the wrong card or miss it — lose a life. You have 3 lives.")
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

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GAME MODE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1)

                        HStack(spacing: 8) {
                            Button(action: { isEndless = false }) {
                                Text("⏱  Timed")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(!isEndless ? .black : .white.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(!isEndless ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.14))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { isEndless = true }) {
                                Text("∞  Endless")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(isEndless ? .black : .white.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(isEndless ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.14))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    if !isEndless {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ROUND LENGTH")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1)

                            HStack(spacing: 8) {
                                ForEach([30, 60, 90], id: \.self) { seconds in
                                    Button(action: { roundLength = seconds }) {
                                        Text("\(seconds) s")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(roundLength == seconds ? .black : .white.opacity(0.8))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(roundLength == seconds ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.14))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .animation(.easeInOut(duration: 0.2), value: isEndless)

                NavigationLink(destination: LightItUpView(roundLength: isEndless ? 0 : roundLength)) {
                    PrimaryButton(
                        title: "START GAME",
                        icon:  "play.fill",
                        color: cyan
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
        LightItUpMenuView()
    }
}
