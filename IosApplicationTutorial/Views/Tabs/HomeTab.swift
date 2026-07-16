import SwiftUI

struct HomeTab: View {

    @AppStorage("playerName")   private var playerName = "Pruthuvi"
    @ObservedObject private var store = SessionStore.shared
    @State private var selectedCategory: String = "All"

    var body: some View {

        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hello,")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)

                                Text(playerName)
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                VStack(alignment: .center, spacing: 2) {
                                    Text("STREAK")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.orange)
                                        Text("\(store.activeStreak)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.16))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .center, spacing: 2) {
                                    Text("SCORE")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(store.totalScore)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.16))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 32)

                        if selectedCategory == "All" {
                            HStack {
                                Text("FEATURED GAME")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)

                            HeroGameTile(
                                mode: .tapFrenzy,
                                destination: AnyView(TapFrenzyMenuView()),
                                highScore: store.highScore(for: .tapFrenzy)
                            )
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }

                        CategoryFilterView(selected: $selectedCategory)
                            .padding(.top, selectedCategory == "All" ? 0 : 8)

                        if selectedCategory == "All" {
                            HStack {
                                Text("MORE GAMES")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                GridGameTile(
                                    mode: .lightItUp,
                                    destination: AnyView(LightItUpMenuView()),
                                    highScore: store.highScore(for: .lightItUp)
                                )
                                GridGameTile(
                                    mode: .quizRush,
                                    destination: AnyView(QuizMenuView()),
                                    highScore: store.highScore(for: .quizRush)
                                )
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 120)
                        } else {
                            let games = GameMode.allCases.filter { $0.category == selectedCategory }
                            
                            if games.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white.opacity(0.15))
                                    
                                    Text("Coming Soon")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("New games in the \(selectedCategory) category will be available soon!")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.4))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                                .padding(.bottom, 120)
                            } else {
                                // Show matching games
                                HStack {
                                    Text("\(selectedCategory.uppercased()) GAMES")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(games, id: \.self) { mode in
                                         GridGameTile(
                                             mode: mode,
                                             destination: AnyView(destination(for: mode)),
                                             highScore: store.highScore(for: mode)
                                         )
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 120)
                            }
                        }
                    }
                }
            }
            .onAppear {
                SessionStore.shared.isTabBarHidden = false
            }
        }
    }

    @ViewBuilder
    private func destination(for mode: GameMode) -> some View {
        switch mode {
        case .tapFrenzy:
            TapFrenzyMenuView()
        case .lightItUp:
            LightItUpMenuView()
        case .quizRush:
            QuizMenuView()
        }
    }
}

struct CategoryFilterView: View {
    let categories = ["All", "Action", "Puzzle", "Quiz", "Adventure"]
    @Binding var selected: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selected = category
                        }
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(selected == category ? .black : .white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selected == category ? Color.white : Color(red: 0.15, green: 0.15, blue: 0.16))
                            )
                            .overlay(
                                Capsule().stroke(Color.white.opacity(selected == category ? 0 : 0.1), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }
}
