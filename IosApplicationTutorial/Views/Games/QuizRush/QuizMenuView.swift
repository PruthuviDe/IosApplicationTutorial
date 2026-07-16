import SwiftUI

struct QuizMenuView: View {

    @AppStorage("quizCategoryId") private var categoryId = 0
    @AppStorage("quizDifficulty") private var difficulty = "any"
    @AppStorage("quizAmount") private var amount = 10
    @AppStorage("quizTimerSeconds") private var timerSeconds = 0
    @State private var isCategoryExpanded = false

    let categories: [(id: Int, name: String)] = [
        (0,  "Any Category"),
        (9,  "General Knowledge"),
        (11, "Film"),
        (12, "Music"),
        (14, "Television"),
        (15, "Video Games"),
        (17, "Science & Nature"),
        (21, "Sports"),
        (22, "Geography"),
        (23, "History"),
        (27, "Animals")
    ]

    let difficulties = ["any", "easy", "medium", "hard"]
    let amounts = [5, 10, 15, 20]
    let timerOptions = [0, 10, 15, 30]

    var selectedCategoryName: String {
        categories.first { $0.id == categoryId }?.name ?? "Any Category"
    }

    func timerLabel(_ seconds: Int) -> String {
        seconds == 0 ? "Off" : "\(seconds)s"
    }

    var body: some View {

        ZStack {
            GeometryReader { geo in
                Image("quiz_rush_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 50)

                VStack(spacing: 12) {
                    Image("quiz_rush")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    VStack(spacing: 4) {
                        Text("Quiz Rush")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("QUIZ")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                    }
                }
                
                Spacer()
                    .frame(height: 30)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Divider()
                            .background(Color.white.opacity(0.08))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1)

                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isCategoryExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Text(selectedCategoryName)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())

                            if isCategoryExpanded {
                                VStack(alignment: .leading, spacing: 0) {
                                    ScrollView(showsIndicators: true) {
                                        VStack(alignment: .leading, spacing: 0) {
                                            ForEach(categories, id: \.id) { category in
                                                Button(action: {
                                                    categoryId = category.id
                                                    withAnimation(.easeInOut(duration: 0.15)) {
                                                        isCategoryExpanded = false
                                                    }
                                                }) {
                                                    Text(category.name)
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundColor(categoryId == category.id ? .white : .white.opacity(0.6))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 12)
                                                        .background(categoryId == category.id ? Color.white.opacity(0.08) : Color.clear)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                if category.id != categories.last?.id {
                                                    Divider()
                                                        .background(Color.white.opacity(0.06))
                                                        .padding(.horizontal, 16)
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: 200)
                                }
                                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.08))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("DIFFICULTY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1)

                            HStack(spacing: 6) {
                                ForEach(difficulties, id: \.self) { level in
                                    Button(action: { difficulty = level }) {
                                        Text(level.capitalized)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(difficulty == level ? .black : .white.opacity(0.8))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(difficulty == level ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.14))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.08))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("QUESTIONS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1)

                            HStack(spacing: 6) {
                                ForEach(amounts, id: \.self) { n in
                                    Button(action: { amount = n }) {
                                        Text("\(n)")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(amount == n ? .black : .white.opacity(0.8))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(amount == n ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.14))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.08))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("TIMER PER QUESTION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(1)

                            HStack(spacing: 6) {
                                ForEach(timerOptions, id: \.self) { seconds in
                                    Button(action: { timerSeconds = seconds }) {
                                        Text(timerLabel(seconds))
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(timerSeconds == seconds ? .black : .white.opacity(0.8))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(timerSeconds == seconds ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.14))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.08))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                NavigationLink(destination: QuizView()) {
                    PrimaryButton(
                        title: "START GAME",
                        icon:  "play.fill",
                        color: Color(red: 0.65, green: 0.35, blue: 0.95)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 10)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            SessionStore.shared.isTabBarHidden = true
        }
    }
}

#Preview {
    NavigationStack {
        QuizMenuView()
    }
}
