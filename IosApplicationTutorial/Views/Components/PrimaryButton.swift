import SwiftUI

// MARK: - PrimaryButton
/// Reusable full-width action button used across menu screens and result screens.
/// Wrap inside a Button or NavigationLink to attach the tap action.
struct PrimaryButton: View {

    let title:  String
    var icon:   String? = nil
    var color:  Color   = .purple

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
            }
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color)
        .cornerRadius(24)
        .shadow(color: color.opacity(0.30), radius: 10)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryButton(title: "START GAME", icon: "play.fill", color: Color(red: 0.20, green: 0.83, blue: 0.95))
        PrimaryButton(title: "PLAY AGAIN", icon: "arrow.clockwise", color: .purple)
    }
    .padding()
    .background(Color.black)
}
