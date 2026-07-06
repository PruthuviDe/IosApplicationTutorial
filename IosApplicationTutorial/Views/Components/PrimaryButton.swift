import SwiftUI

struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var color: Color = .purple

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(title)
        }
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color)
        .cornerRadius(14)
    }
}
