import SwiftUI

struct GameTile: View {

    let mode: GameMode
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {

                Image(systemName: mode.icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(mode.accentColor.opacity(0.25))
                    .cornerRadius(14)

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(mode.subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(mode.accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}
