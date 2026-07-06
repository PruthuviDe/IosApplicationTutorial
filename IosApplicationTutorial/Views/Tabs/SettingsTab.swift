import SwiftUI

struct SettingsTab: View {

    @ObservedObject private var store = SessionStore.shared
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("challengeHour") private var challengeHour = 9
    @AppStorage("challengeMinute") private var challengeMinute = 0
    @State private var showResetConfirm = false
    @State private var challengeTime = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader("DAILY CHALLENGE")

                            Toggle(isOn: $notificationsEnabled) {
                                Label("Enable Notifications", systemImage: "bell.fill")
                                    .foregroundColor(.white)
                            }
                            .tint(.purple)
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)
                            .onChange(of: notificationsEnabled) {
                                if notificationsEnabled {
                                    NotificationService.shared.requestPermission()
                                    NotificationService.shared.scheduleDailyChallenge(hour: challengeHour, minute: challengeMinute)
                                } else {
                                    NotificationService.shared.cancelAll()
                                }
                            }

                            if notificationsEnabled {
                                DatePicker(
                                    "Challenge Time",
                                    selection: $challengeTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .padding(14)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(12)
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

                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader("DATA")

                            HStack {
                                Label("Games Recorded", systemImage: "gamecontroller.fill")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(store.totalGamesPlayed)")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)

                            Button {
                                showResetConfirm = true
                            } label: {
                                Label("Reset All Stats", systemImage: "trash.fill")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
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

                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader("ABOUT")

                            HStack {
                                Label("PlayHub", systemImage: "gamecontroller.fill")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Week 4")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white.opacity(0.4))
    }
}

#Preview {
    SettingsTab()
}
