import SwiftUI

// MARK: - PrimaryButtonStyleType
enum PrimaryButtonStyleType {
    case filled
    case outlined
}

// MARK: - PrimaryButton
/// A clean, simple, and proportional button matching the standard iOS design language.
/// Avoids over-designed glows and fits cleanly inside the view without stretching edge-to-edge.
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
            }
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundColor(style == .filled ? .white : color)
        .frame(width: 280) // Capped width so it's not too large/stretched on screen
        .padding(.vertical, 12) // Compact vertical padding
        .background(
            Group {
                if style == .filled {
                    color
                } else {
                    Color.clear
                }
            }
        )
        .cornerRadius(10) // Simple, clean rounded corners
        .overlay(
            Group {
                if style == .outlined {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: 1.5) // Simple clean outline
                }
            }
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
