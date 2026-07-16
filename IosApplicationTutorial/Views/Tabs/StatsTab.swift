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
                            VStack(spacing: 32) {
                                let filteredCount = selectedGame == "All"
                                    ? store.totalGamesPlayed
                                    : store.sessions.filter { $0.mode.rawValue == selectedGame }.count

                                let bestScore: Int = {
                                    if selectedGame == "All" {
                                        return store.sessions.map { $0.score }.max() ?? 0
                                    } else if let mode = GameMode.allCases.first(where: { $0.rawValue == selectedGame }) {
                                        return store.highScore(for: mode)
                                    }
                                    return 0
                                }()

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    StatWidget(
                                        title: "Games Played",
                                        value: "\(filteredCount)",
                                        icon: "gamecontroller.fill",
                                        color: .cyan
                                    )
                                    StatWidget(
                                        title: "Best Score",
                                        value: "\(bestScore)",
                                        icon: "trophy.fill",
                                        color: .yellow
                                    )
                                    StatWidget(
                                        title: "Day Streak",
                                        value: "\(store.activeStreak)",
                                        icon: "flame.fill",
                                        color: .orange
                                    )
                                    StatWidget(
                                        title: "Total Score",
                                        value: selectedGame == "All"
                                            ? "\(store.totalScore)"
                                            : "\(store.sessions.filter { $0.mode.rawValue == selectedGame }.map { $0.score }.reduce(0, +))",
                                        icon: "chart.bar.fill",
                                        color: .purple
                                    )
                                }
                                .padding(.horizontal, 24)

                                if selectedGame == "All" {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("PERSONAL BESTS")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.secondary)
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
                                                .padding(.vertical, 14)
                                                .padding(.horizontal, 16)

                                                if idx < GameMode.allCases.count - 1 {
                                                    Divider()
                                                        .background(Color.white.opacity(0.06))
                                                        .padding(.leading, 66)
                                                }
                                            }
                                        }
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color.white.opacity(0.025))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 18)
                                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                                )
                                        )
                                        .padding(.horizontal, 24)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    
                                    HStack {
                                        Text("SCORE HISTORY")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(gamesList, id: \.self) { game in
                                                Button(action: { selectedGame = game }) {
                                                    Text(game)
                                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                        .foregroundColor(selectedGame == game ? .black : .white.opacity(0.8))
                                                        .padding(.horizontal, 20)
                                                        .padding(.vertical, 8)
                                                        .background(
                                                            Capsule()
                                                                .fill(selectedGame == game ? Color.white : Color(red: 0.15, green: 0.15, blue: 0.16))
                                                        )
                                                        .overlay(
                                                            Capsule().stroke(Color.white.opacity(selectedGame == game ? 0 : 0.1), lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                    
                                    let chartData = store.sessions
                                        .filter { selectedGame == "All" || $0.mode.rawValue == selectedGame }
                                        .sorted { $0.timestamp < $1.timestamp }
                                        .enumerated()
                                        .map { (index: $0.offset, session: $0.element) }
                                    
                                    let chartColor = selectedGame == "All" ? Color.cyan : (GameMode.allCases.first(where: { $0.rawValue == selectedGame })?.accentColor ?? .cyan)
                                    
                                    VStack {
                                        if chartData.isEmpty {
                                            Text("No data for \(selectedGame)")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .frame(height: 200)
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
                                                            colors: [chartColor, chartColor.opacity(0.3)],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    )
                                                    .cornerRadius(4)
                                                }
                                            }
                                            .frame(height: 200)
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
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("RECENT GAMES")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.secondary)
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
                                                .padding(.vertical, 14)
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
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white.opacity(0.025))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18)
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
