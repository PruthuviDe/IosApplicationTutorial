import SwiftUI

struct SettingsTab: View {

    @ObservedObject private var store = SessionStore.shared
    @AppStorage("playerName")           private var playerName = "Player One"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("challengeHour")        private var challengeHour = 9
    @AppStorage("challengeMinute")      private var challengeMinute = 0
    @State private var showResetConfirm = false
    @State private var challengeTime = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    colors: [Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.24), Color.black],
                    center: .top,
                    startRadius: 10,
                    endRadius: 400
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("App Configurations")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                            
                            Text("Settings")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {

                            // PLAYER PROFILE CARD
                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader("PLAYER PROFILE")

                                HStack {
                                    Label("Display Name", systemImage: "person.fill")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    TextField("Your name", text: $playerName)
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: 140)
                                        .autocorrectionDisabled()
                                }
                                .padding(.vertical, 4)
                            }
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )

                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader("DAILY CHALLENGE")

                                Toggle(isOn: $notificationsEnabled) {
                                    Label("Enable Notifications", systemImage: "bell.fill")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .tint(Color(red: 0.65, green: 0.35, blue: 0.95))
                                .padding(.vertical, 4)
                                .onChange(of: notificationsEnabled) {
                                    if notificationsEnabled {
                                        NotificationService.shared.requestPermission()
                                        NotificationService.shared.scheduleDailyChallenge(hour: challengeHour, minute: challengeMinute)
                                    } else {
                                        NotificationService.shared.cancelAll()
                                    }
                                }

                                if notificationsEnabled {
                                    Divider()
                                        .background(Color.white.opacity(0.08))

                                    DatePicker(
                                        "Challenge Time",
                                        selection: $challengeTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .colorScheme(.dark)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .padding(.vertical, 4)
                                    .onChange(of: challengeTime) {
                                        let cal = Calendar.current
                                        let h = cal.component(.hour, from: challengeTime)
                                        let m = cal.component(.minute, from: challengeTime)
                                        challengeHour = h
                                        challengeMinute = m
                                        NotificationService.shared.scheduleDailyChallenge(hour: h, minute: m)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )

                            // DATA GROUP CARD
                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader("DATA & HISTORY")

                                HStack {
                                    Label("Games Recorded", systemImage: "gamecontroller.fill")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(store.totalGamesPlayed)")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.40))
                                }
                                .padding(.vertical, 4)

                                Divider()
                                    .background(Color.white.opacity(0.08))

                                Button {
                                    showResetConfirm = true
                                } label: {
                                    Label("Reset All Stats", systemImage: "trash.fill")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 0.92, green: 0.26, blue: 0.35))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 4)
                                }
                                .confirmationDialog(
                                    "Reset All Stats?",
                                    isPresented: $showResetConfirm,
                                    titleVisibility: .visible
                                ) {
                                    Button("Reset Everything", role: .destructive) {
                                        store.resetAll()
                                    }
                                    Button("Cancel", role: .cancel) { }
                                } message: {
                                    Text("This will permanently delete all game sessions, scores, and history.")
                                }
                            }
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )

                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader("ABOUT APP")

                                HStack {
                                    Label("PlayHub", systemImage: "gamecontroller.fill")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("v1.2.0")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.40))
                                }
                                .padding(.vertical, 4)
                            }
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.09, blue: 0.14), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                var comps = DateComponents()
                comps.hour = challengeHour
                comps.minute = challengeMinute
                challengeTime = Calendar.current.date(from: comps) ?? Date()
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color(red: 0.65, green: 0.35, blue: 0.95))
            .tracking(1.5)
            .padding(.bottom, 2)
    }
}

#Preview {
    SettingsTab()
}
