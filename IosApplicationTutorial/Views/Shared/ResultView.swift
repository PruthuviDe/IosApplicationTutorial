import SwiftUI

struct ResultView: View {

    let mode:      GameMode
    let score:     Int
    let onRestart: () -> Void

    @ObservedObject private var store = SessionStore.shared
    @State private var isNewBest = false

    var currentBest: Int { store.highScore(for: mode) }

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Text("GAME OVER")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)

            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(score)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("PTS")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(mode.accentColor)
                }

                if isNewBest {
                    Text("NEW PERSONAL BEST")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.yellow)
                        .tracking(2)
                } else {
                    Text("BEST: \(currentBest) PTS")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(2)
                }
            }

            Spacer()

            VStack(spacing: 20) {
                Button(action: onRestart) {
                    PrimaryButton(
                        title: "PLAY AGAIN",
                        icon: "arrow.clockwise",
                        color: mode.accentColor
                    )
                }
                .buttonStyle(PlainButtonStyle())

                ShareLink(item: "I just scored \(score) on \(mode.rawValue) in GameVault — beat that! 🎮") {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share Score")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(mode.accentColor.opacity(0.90))
                    .padding(.vertical, 8)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                GeometryReader { geo in
                    Image(mode.imageName + "_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea()

                Color.black.opacity(0.85)
                    .ignoresSafeArea()
            }
        )
        .ignoresSafeArea(.all)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            isNewBest = score > store.highScore(for: mode)
        }
    }
}

#Preview {
    ResultView(
        mode:      .tapFrenzy,
        score:     42,
        onRestart: {}
    )
}
