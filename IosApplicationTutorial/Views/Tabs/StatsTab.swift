import SwiftUI

struct StatsTab: View {

    @ObservedObject private var store = SessionStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if store.sessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.2))
                        Text("No games yet")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.4))
                        Text("Play a game to see your stats here.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.3))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {

                            HStack(spacing: 12) {
                                ScoreBadge(
                                    label: "Games Played",
                                    value: "\(store.totalGamesPlayed)",
                                    icon: "gamecontroller.fill",
                                    color: .purple
                                )
                                ScoreBadge(
                                    label: "Total Score",
                                    value: "\(store.totalScore)",
                                    icon: "star.fill",
                                    color: .yellow
                                )
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("PERSONAL BESTS")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.4))

                                ForEach(GameMode.allCases, id: \.self) { mode in
                                    HStack(spacing: 12) {
                                        Image(systemName: mode.icon)
                                            .foregroundColor(mode.accentColor)
                                            .frame(width: 32)
                                        Text(mode.rawValue)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(store.highScore(for: mode))")
                                            .fontWeight(.bold)
                                            .foregroundColor(mode.accentColor)
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(10)
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("RECENT GAMES")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.4))

                                ForEach(store.recentSessions) { session in
                                    HStack(spacing: 12) {
                                        Image(systemName: session.mode.icon)
                                            .foregroundColor(session.mode.accentColor)
                                            .frame(width: 32)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(session.mode.rawValue)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Text(session.timestamp, style: .relative)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        Spacer()
                                        Text("\(session.score)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    StatsTab()
}
