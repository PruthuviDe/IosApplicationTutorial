import SwiftUI

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
        .frame(width: 240) 
        .padding(.vertical, 14) 
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(Capsule()) 
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.15), lineWidth: 1.2) 
        )
        .shadow(
            color: Color.black.opacity(0.35), 
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
