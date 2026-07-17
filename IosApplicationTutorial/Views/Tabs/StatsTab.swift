import SwiftUI
import Charts

struct StatsTab: View {
    
    @StateObject private var vm    = StatsViewModel()
    @ObservedObject private var store = SessionStore.shared
    
    @State private var selectedGame: String = "All"
    
    var gamesList: [String] {
        var list = ["All"]
        list.append(contentsOf: GameMode.allCases.map { $0.rawValue })
        return list
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.06, blue: 0.08).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 24)
                        
                        if store.sessions.isEmpty {
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: 100, height: 100)
                                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                    
                                    Image(systemName: "chart.xyaxis.line")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(spacing: 6) {
                                    Text("No games yet")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text("Play a game to start tracking your performance.")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 48)
                                }
                            }
                            .padding(.top, 60)
                        } else {
                            VStack(spacing: 24) {
                                HStack(spacing: 4) {
                                    ForEach(gamesList, id: \.self) { game in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedGame = game
                                            }
                                        }) {
                                            Text(game)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                                .foregroundColor(selectedGame == game ? .black : .white.opacity(0.8))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    Capsule()
                                                        .fill(selectedGame == game ? Color.white : Color.clear)
                                                )
                                        }
                                    }
                                }
                                .padding(4)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .padding(.horizontal, 24)
                                .padding(.top, 8)

                                let filteredCount = selectedGame == "All"
                                    ? store.totalGamesPlayed
                                    : store.sessions.filter { $0.mode.rawValue == selectedGame }.count

                                let bestScore = selectedGame == "All"
                                    ? (store.sessions.map { $0.score }.max() ?? 0)
                                    : store.highScore(for: GameMode.allCases.first(where: { $0.rawValue == selectedGame }) ?? .tapFrenzy)

                                let thirdStatTitle = selectedGame == "All" ? "DAY STREAK" : "TOTAL POINTS"
                                let thirdStatValue = selectedGame == "All"
                                    ? "\(store.activeStreak) Days"
                                    : "\(store.sessions.filter { $0.mode.rawValue == selectedGame }.map { $0.score }.reduce(0, +))"
                                
                                let activeAccent = selectedGame == "All" ? Color.cyan : (GameMode.allCases.first(where: { $0.rawValue == selectedGame })?.accentColor ?? .cyan)

                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("GAMES")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .tracking(1)
                                        Text("\(filteredCount)")
                                            .font(.system(size: 24, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.6)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.1))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 8)
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("BEST SCORE")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .tracking(1)
                                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                                            Text("\(bestScore)")
                                                .font(.system(size: 24, weight: .black, design: .rounded))
                                                .foregroundColor(.white)
                                            Text("PTS")
                                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                                .foregroundColor(activeAccent)
                                        }
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.1))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 8)
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(thirdStatTitle)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .tracking(1)
                                        Text(thirdStatValue)
                                            .font(.system(size: 24, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.6)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.03))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 24)

                                let chartData = store.sessions
                                    .filter { selectedGame == "All" || $0.mode.rawValue == selectedGame }
                                    .sorted { $0.timestamp < $1.timestamp }
                                    .enumerated()
                                    .map { (index: $0.offset, session: $0.element) }

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("PERFORMANCE TREND")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .tracking(1)
                                        .padding(.horizontal, 24)

                                    VStack {
                                        if chartData.isEmpty {
                                            Text("No data for \(selectedGame)")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .frame(height: 180)
                                                .frame(maxWidth: .infinity)
                                        } else {
                                            Chart {
                                                ForEach(chartData, id: \.index) { item in
                                                    BarMark(
                                                        x: .value("Game", item.index + 1),
                                                        y: .value("Score", item.session.score),
                                                        width: .fixed(12)
                                                    )
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            colors: [activeAccent, activeAccent.opacity(0.3)],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    )
                                                    .cornerRadius(4)
                                                }
                                            }
                                            .frame(height: 180)
                                            .chartScrollableAxes(.horizontal)
                                            .chartXVisibleDomain(length: 15)
                                            .chartXAxis {
                                                AxisMarks(values: .automatic) { _ in
                                                    AxisValueLabel()
                                                        .foregroundStyle(Color.secondary.opacity(0.5))
                                                        .font(.system(size: 9, weight: .bold))
                                                }
                                            }
                                            .chartYAxis {
                                                AxisMarks(position: .leading) { value in
                                                    AxisGridLine()
                                                        .foregroundStyle(Color.white.opacity(0.05))
                                                    AxisValueLabel()
                                                        .foregroundStyle(Color.secondary.opacity(0.5))
                                                        .font(.system(size: 10, weight: .bold))
                                                }
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.white.opacity(0.03))
                                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
                                    )
                                    .padding(.horizontal, 24)
                                }

                                if selectedGame == "All" {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("PERSONAL BESTS")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .tracking(1)
                                            .padding(.horizontal, 24)

                                        VStack(spacing: 0) {
                                            ForEach(Array(GameMode.allCases.enumerated()), id: \.element) { idx, mode in
                                                HStack(spacing: 14) {
                                                    Image(mode.imageName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 36, height: 36)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                        )

                                                    Text(mode.rawValue)
                                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                                        .foregroundColor(.white)

                                                    Spacer()

                                                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                                                        Text("\(store.highScore(for: mode))")
                                                            .font(.system(size: 16, weight: .black, design: .rounded))
                                                            .foregroundColor(.white)
                                                        Text("PTS")
                                                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                                                            .foregroundColor(mode.accentColor)
                                                    }
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 16)

                                                if idx < GameMode.allCases.count - 1 {
                                                    Divider()
                                                        .background(Color.white.opacity(0.06))
                                                        .padding(.leading, 66)
                                                }
                                            }
                                        }
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.white.opacity(0.025))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                                )
                                        )
                                        .padding(.horizontal, 24)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("RECENT GAMES")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .tracking(1)
                                        .padding(.horizontal, 24)

                                    VStack(spacing: 0) {
                                        let filteredSessions = store.recentSessions.filter { selectedGame == "All" || $0.mode.rawValue == selectedGame }

                                        if filteredSessions.isEmpty {
                                            Text("No recent games")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .padding(.vertical, 24)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                        } else {
                                            let sessionsArray = Array(filteredSessions.enumerated())
                                            ForEach(sessionsArray, id: \.element.id) { index, session in
                                                HStack(spacing: 14) {
                                                    Image(session.mode.imageName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 40, height: 40)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                        )
                                                    
                                                    VStack(alignment: .leading, spacing: 3) {
                                                        Text(session.mode.rawValue)
                                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                                            .foregroundColor(.white)
                                                        
                                                        HStack(spacing: 4) {
                                                            Image(systemName: "clock")
                                                                .font(.system(size: 10))
                                                                .foregroundColor(.secondary)
                                                            Text(session.timestamp, style: .relative)
                                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                                                        Text("\(session.score)")
                                                            .font(.system(size: 16, weight: .black, design: .rounded))
                                                            .foregroundColor(.white)
                                                        Text("PTS")
                                                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                                                            .foregroundColor(session.mode.accentColor)
                                                    }
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 16)
                                                
                                                if index < sessionsArray.count - 1 {
                                                    Divider()
                                                        .background(Color.white.opacity(0.06))
                                                        .padding(.leading, 70)
                                                }
                                            }
                                        }
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.025))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                            )
                                    )
                                    .padding(.horizontal, 24)
                                }
                                
                            }
                            .padding(.bottom, 120)
                        }
                    }
                }
            }
            .onAppear {
                SessionStore.shared.isTabBarHidden = false
            }
        }
    }
}

struct StatWidget: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(color.opacity(0.08))
                .offset(x: 10, y: 10)
                .rotationEffect(.degrees(-15))
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(color.opacity(0.3), lineWidth: 1))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
