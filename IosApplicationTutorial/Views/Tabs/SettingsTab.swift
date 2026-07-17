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
                Color(red: 0.05, green: 0.06, blue: 0.08).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 20) {
                                ZStack {
                                    Image("player_avatar")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 64, height: 64)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PLAYER PROFILE")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .tracking(1.5)
                                    
                                    HStack(spacing: 6) {
                                        TextField("Your name", text: $playerName)
                                            .font(.system(size: 20, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                            .autocorrectionDisabled()
                                            .frame(maxWidth: 180)
                                        
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                }
                                Spacer()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.03))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.08), .white.opacity(0.01)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GAME ALERTS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1.0)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                Toggle(isOn: $notificationsEnabled) {
                                    HStack {
                                        SettingIcon(icon: "bell.fill", color: Color(red: 0.92, green: 0.26, blue: 0.35))
                                        Text("Daily Reminders")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                    }
                                }
                                .tint(Color(red: 0.20, green: 0.83, blue: 0.95))
                                .padding(16)
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
                                        .padding(.leading, 56)
                                    
                                    HStack {
                                        SettingIcon(icon: "clock.fill", color: Color(red: 0.20, green: 0.83, blue: 0.95))
                                        Text("Alert Time")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        DatePicker(
                                            "",
                                            selection: $challengeTime,
                                            displayedComponents: .hourAndMinute
                                        )
                                        .labelsHidden()
                                        .onChange(of: challengeTime) {
                                            let cal = Calendar.current
                                            let h = cal.component(.hour, from: challengeTime)
                                            let m = cal.component(.minute, from: challengeTime)
                                            challengeHour = h
                                            challengeMinute = m
                                            NotificationService.shared.scheduleDailyChallenge(hour: h, minute: m)
                                        }
                                    }
                                    .padding(16)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.03))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PLAYER DATA")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1.0)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    SettingIcon(icon: "gamecontroller.fill", color: Color(red: 0.65, green: 0.35, blue: 0.95))
                                    Text("Games Recorded")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(store.totalGamesPlayed)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                Button {
                                    showResetConfirm = true
                                } label: {
                                    HStack {
                                        SettingIcon(icon: "trash.fill", color: .red)
                                        Text("Reset All Stats")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.red)
                                        Spacer()
                                    }
                                }
                                .padding(16)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.03))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ABOUT APP")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1.0)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    SettingIcon(icon: "info.circle.fill", color: .gray)
                                    Text("GameVault")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("v1.2.0")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.03))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .onAppear {
                var comps = DateComponents()
                comps.hour = challengeHour
                comps.minute = challengeMinute
                challengeTime = Calendar.current.date(from: comps) ?? Date()
                SessionStore.shared.isTabBarHidden = false
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
    }
}

struct SettingIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        let isDestructive = icon == "trash.fill"
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isDestructive ? Color.red.opacity(0.08) : Color.white.opacity(0.04))
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isDestructive ? Color.red.opacity(0.15) : Color.white.opacity(0.08), lineWidth: 1)
                )
            
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isDestructive ? .red : .white.opacity(0.75))
        }
        .padding(.trailing, 8)
    }
}

#Preview {
    SettingsTab()
}
