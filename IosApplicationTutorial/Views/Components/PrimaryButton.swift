import SwiftUI

// MARK: - PrimaryButtonStyleType
enum PrimaryButtonStyleType {
    case filled
    case outlined
}

// MARK: - PrimaryButton
/// A highly polished, custom action button styled for GameVault.
/// Supports filled (gradient + glow) and outlined (glassmorphic + accent border) styles.
struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var color: Color = .purple
    var style: PrimaryButtonStyleType = .filled

    var body: some View {
        HStack(spacing: 10) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
            }
            Text(title.uppercased())
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .tracking(1.5)
        }
        .foregroundColor(style == .filled ? .white : color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            Group {
                if style == .filled {
                    // Deep gaming gradient fill
                    LinearGradient(
                        colors: [color, color.opacity(0.70)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    // Dark translucent backdrop
                    Color.white.opacity(0.04)
                }
            }
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    style == .filled 
                        ? LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.10)],
                            startPoint: .top,
                            endPoint: .bottom
                          )
                        : LinearGradient(
                            colors: [color.opacity(0.40), color.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                          ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: color.opacity(style == .filled ? 0.35 : 0.12),
            radius: style == .filled ? 14 : 8,
            x: 0,
            y: style == .filled ? 6 : 3
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
