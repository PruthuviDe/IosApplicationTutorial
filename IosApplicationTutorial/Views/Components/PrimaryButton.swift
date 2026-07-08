import SwiftUI

// MARK: - PrimaryButton
/// A clean, flat, and high-contrast primary button designed for GameVault.
/// Follows Apple's HIG and modern mobile game patterns:
/// - Prominent, solid background color matching the game mode's theme.
/// - Clear, high-contrast white text and bold icons.
/// - Compact, consistent sizing (280pt width) fitting comfortably in the thumb zone.
/// - Flat style with no distracting outer borders, glowing shadows, or extra overlays.
struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var color: Color = .purple

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
            }
            Text(title.uppercased())
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .frame(width: 280) // Clean, centered proportional width
        .padding(.vertical, 14) // Compact vertical touch target (44pt+ safe target)
        .background(color) // Solid vibrant theme color
        .cornerRadius(12) // Clean, modern rounded corners matching game cards
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(
            title: "START GAME",
            icon: "play.fill",
            color: Color(red: 0.20, green: 0.83, blue: 0.95)
        )
        
        PrimaryButton(
            title: "PLAY AGAIN",
            icon: "arrow.clockwise",
            color: .purple
        )
    }
    .padding()
    .background(Color.black)
}
