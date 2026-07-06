import SwiftUI

struct ScoreBadge: View {

    let label: String
    let value: String
    var icon: String? = nil
    var color: Color = .yellow

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.07))
        .cornerRadius(12)
    }
}
