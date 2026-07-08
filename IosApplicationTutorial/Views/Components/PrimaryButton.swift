import SwiftUI

// MARK: - PrimaryButtonStyleType
enum PrimaryButtonStyleType {
    case filled
    case outlined
}

// MARK: - PrimaryButton
/// A refined, glassmorphic button matching the design system of GameVault.
/// Uses semi-translucent backdrops and borders to match the existing game panels.
/// Features a compact size, consistent uppercase layout, and no glowing shadows.
struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var color: Color = .purple
    var style: PrimaryButtonStyleType = .filled

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(style == .filled ? color : .white.opacity(0.8)) // Tinted icon for filled, dim white for outlined
            }
            
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .tracking(1.0)
        }
        .frame(width: 280) // Unified compact width
        .padding(.vertical, 14) // Balanced vertical height
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    style == .filled
                        ? color.opacity(0.16) // Translucent accent glass fill
                        : Color.white.opacity(0.05) // Translucent neutral glass fill
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    style == .filled
                        ? color.opacity(0.50) // Accent border
                        : Color.white.opacity(0.15), // Neutral border
                    lineWidth: 1.2
                )
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(
            title: "START GAME",
            icon: "play.fill",
            color: Color(red: 0.20, green: 0.83, blue: 0.95),
            style: .filled
        )
        
        PrimaryButton(
            title: "SHARE SCORE",
            icon: "square.and.arrow.up",
            color: Color(red: 0.20, green: 0.83, blue: 0.95),
            style: .outlined
        )
    }
    .padding()
    .background(Color.black)
}
