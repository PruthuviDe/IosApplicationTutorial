import SwiftUI
import Charts

struct StatsTab: View {

    @ObservedObject private var store = SessionStore.shared

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
                            Text("Your Performance")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                            
                            Text("Stats & History")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    if store.sessions.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.03))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1.5)
                                    )

                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                            }

                            VStack(spacing: 6) {
                                Text("No games yet")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Play a game from the home tab to start recording stats.")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.40))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 48)
                            }
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 24) {

                                HStack(spacing: 12) {
                                    ScoreBadge(
                                        label: "Games Played",
                                        value: "\(store.totalGamesPlayed)",
                                        icon: "gamecontroller.fill",
                                        color: Color(red: 0.65, green: 0.35, blue: 0.95)
                                    )
                                    ScoreBadge(
                                        label: "Total Score",
                                        value: "\(store.totalScore)",
                                        icon: "star.fill",
                                        color: .yellow
                                    )
                                }

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("PERSONAL BESTS")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.4))
                                        .tracking(1.5)

                                    VStack(spacing: 10) {
                                        ForEach(GameMode.allCases, id: \.self) { mode in
                                            HStack(spacing: 14) {
                                                 Image(mode.imageName)
                                                     .resizable()
                                                     .aspectRatio(contentMode: .fill)
                                                     .frame(width: 38, height: 38)
                                                     .cornerRadius(10)
                                                     .overlay(
                                                         RoundedRectangle(cornerRadius: 10)
                                                             .stroke(mode.accentColor.opacity(0.20), lineWidth: 1)
                                                     )

                                                Text(mode.rawValue)
                                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.white)

                                                Spacer()

                                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                                    Text("\(store.highScore(for: mode))")
                                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                                        .foregroundColor(mode.accentColor)
                                                    Text("pts")
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .foregroundColor(.white.opacity(0.3))
                                                }
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                            )
                                        }
                                    }
                                }

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("SCORE HISTORY")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.4))
                                        .tracking(1.5)

                                    Chart {
                                        ForEach(store.recentSessions) { session in
                                            BarMark(
                                                x: .value("Game", session.timestamp, unit: .second),
                                                y: .value("Score", session.score)
                                            )
                                            .foregroundStyle(session.mode.accentColor)
                                            .cornerRadius(4)
                                        }
                                    }
                                    .frame(height: 140)
                                    .chartXAxis(.hidden)
                                    .chartYAxis {
                                        AxisMarks(position: .leading) { value in
                                            AxisGridLine()
                                                .foregroundStyle(Color.white.opacity(0.06))
                                            AxisValueLabel()
                                                .foregroundStyle(Color.white.opacity(0.35))
                                                .font(.system(size: 10, weight: .medium))
                                        }
                                    }
                                    .padding(14)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )

                                    HStack(spacing: 16) {
                                        ForEach(GameMode.allCases, id: \.self) { mode in
                                            HStack(spacing: 6) {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(mode.accentColor)
                                                    .frame(width: 12, height: 12)
                                                Text(mode.rawValue)
                                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                                    .foregroundColor(.white.opacity(0.45))
                                            }
                                        }
                                    }
                                }

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("RECENT GAMES")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.4))
                                        .tracking(1.5)

                                    VStack(spacing: 10) {
                                        ForEach(store.recentSessions) { session in
                                            HStack(spacing: 14) {
                                                 Image(session.mode.imageName)
                                                     .resizable()
                                                     .aspectRatio(contentMode: .fill)
                                                     .frame(width: 38, height: 38)
                                                     .cornerRadius(10)

                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(session.mode.rawValue)
                                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                        .foregroundColor(.white)
                                                    Text(session.timestamp, style: .relative)
                                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                                        .foregroundColor(.white.opacity(0.35))
                                                }

                                                Spacer()

                                                Text("+\(session.score)")
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.05), Color.white.opacity(0.01)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
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
        }
    }
}

#Preview {
    StatsTab()
}
