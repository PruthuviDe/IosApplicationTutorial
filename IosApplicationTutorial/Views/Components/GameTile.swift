import SwiftUI

// MARK: - GameTile
/// A home-screen game card that navigates to its game view.
/// Displays the game icon, title, subtitle, and a clean, high-contrast
/// high score indicator aligned with the game's theme color.
struct GameTile: View {

    let mode:        GameMode
    let destination: AnyView
    let highScore:   Int

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {

                // Game artwork icon
                Image(mode.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(mode.accentColor.opacity(0.30), lineWidth: 1.2)
                    )

                // Title + Subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(mode.subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.40))
                }

                Spacer()

                // High score layout (Clean & Modern)
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("BEST")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.white.opacity(0.30))
                            .tracking(1.0)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(highScore)")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(mode.accentColor)
                            
                            Text("pts")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.30))
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.18))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.06), mode.accentColor.opacity(0.015)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.10), mode.accentColor.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GameTile(
        mode:        .tapFrenzy,
        destination: AnyView(Text("Tap Frenzy")),
        highScore:   1382
    )
    .padding()
    .background(Color.black)
}
