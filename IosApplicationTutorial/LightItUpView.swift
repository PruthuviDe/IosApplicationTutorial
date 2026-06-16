import SwiftUI

struct LightItUpView: View {

    var body: some View {

        VStack(spacing: 20) {

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color.cyan.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

#Preview {
    LightItUpView()
}
