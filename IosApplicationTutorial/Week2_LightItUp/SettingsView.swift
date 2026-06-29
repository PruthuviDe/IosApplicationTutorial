import SwiftUI

struct SettingsView: View {

    @AppStorage("roundLength") private var roundLength = 60

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        VStack(spacing: 32) {

            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            VStack(alignment: .leading, spacing: 12) {

                Text("Round Length")
                    .font(.headline)

                Picker("Round Length", selection: $roundLength) {
                    Text("30 sec").tag(30)
                    Text("60 sec").tag(60)
                    Text("90 sec").tag(90)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 24)

            Text("Applies to Light It Up only")
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.cyan)
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    SettingsView()
}
