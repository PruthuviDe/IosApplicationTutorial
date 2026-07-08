import SwiftUI

// MARK: - PrimaryButton
/// A clean, compact, pill-shaped primary action button.
/// Follows premium iOS mobile game interfaces:
/// - Friendly Capsule shape with a compact, balanced width (240pt).
/// - Rich visual depth using a soft vertical gradient of the theme color.
/// - A thin, semi-translucent top bezel stroke (15% white) for a subtle 3D molded effect.
/// - A soft, standard dark shadow (35% black) for a floating lift without distracting neon glows.
struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var color: Color = .purple

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
            }
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .frame(width: 240) // Compact centered width (prevents stretching)
        .padding(.vertical, 14) // Balanced, comfortable touch target height
        .background(
            // Soft vertical gradient for premium depth
            LinearGradient(
                colors: [color, color.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(Capsule()) // Friendly, premium capsule shape
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.15), lineWidth: 1.2) // Subtle bevel highlight
        )
        .shadow(
            color: Color.black.opacity(0.35), // Dark shadow for depth (no glowing neon)
            radius: 5,
            x: 0,
            y: 3
        )
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
