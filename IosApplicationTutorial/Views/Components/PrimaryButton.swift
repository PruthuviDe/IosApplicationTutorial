import SwiftUI

// MARK: - PrimaryButtonStyleType
enum PrimaryButtonStyleType {
    case filled
    case outlined
}

// MARK: - PrimaryButton
/// A premium, high-tech gaming button designed to match GameVault's dark theme.
/// Replaces generic solid-color buttons with a dark-glass cyberpunk panel,
/// featuring vibrant glowing neon borders, white titles, and tinted icons.
struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var color: Color = .purple
    var style: PrimaryButtonStyleType = .filled

    var body: some View {
        HStack(spacing: 10) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color) // Tinted icon
            }
            
            Text(title.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white) // Always clean white text
                .tracking(2.0) // Arcade character spacing
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            ZStack {
                // Cyberpunk dark carbon backplate
                Color.black.opacity(0.65)
                
                if style == .filled {
                    // Soft internal radial/linear glow
                    LinearGradient(
                        colors: [color.opacity(0.15), color.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    // Translucent backing
                    Color.white.opacity(0.02)
                }
            }
        )
        .cornerRadius(12) // Sleek, modern corner radius instead of pill shape
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: style == .filled
                            ? [color, color.opacity(0.40)]
                            : [color.opacity(0.45), color.opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: style == .filled ? 2.0 : 1.2
                )
        )
        // High-tech subtle inner bezel highlight
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .padding(1)
        )
        .shadow(
            color: color.opacity(style == .filled ? 0.35 : 0.08),
            radius: style == .filled ? 12 : 6,
            x: 0,
            y: style == .filled ? 4 : 2
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
