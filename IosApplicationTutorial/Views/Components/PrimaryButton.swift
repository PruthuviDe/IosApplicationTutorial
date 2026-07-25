import SwiftUI

struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var color: Color = .purple

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.fill")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(color)
            
            Text(title.uppercased())
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .tracking(1.5)
        }
        .frame(width: 240) 
        .padding(.vertical, 15) 
        .background(
            Color(red: 0.07, green: 0.08, blue: 0.11)
        )
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(color, lineWidth: 3)
        )
        .shadow(color: color.opacity(0.55), radius: 0, x: 5, y: 5)
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.06, blue: 0.08).ignoresSafeArea()
        VStack(spacing: 24) {
            PrimaryButton(
                title: "START GAME",
                color: .orange
            )
            
            PrimaryButton(
                title: "PLAY AGAIN",
                color: .cyan
            )
        }
        .padding()
    }
}
