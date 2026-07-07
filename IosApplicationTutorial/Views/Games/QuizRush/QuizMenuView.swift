import SwiftUI

struct QuizMenuView: View {

    @AppStorage("quizCategoryId") private var categoryId = 0
    @AppStorage("quizDifficulty") private var difficulty = "any"
    @AppStorage("quizAmount") private var amount = 10
    @AppStorage("quizTimerSeconds") private var timerSeconds = 0

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
            RadialGradient(
                colors: [Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.18), Color.black],
                center: .top,
                startRadius: 10,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        VStack(spacing: 8) {
                            Image("quiz_rush")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(18)
                                .shadow(color: Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.35), radius: 12)

                            Text("Quiz Rush")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(0.5)

                            Text("\(amount) questions · tap fast · build your streak")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 24)

                        VStack(spacing: 16) {

                            VStack(alignment: .leading, spacing: 10) {
                                Text("CATEGORY")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.65, green: 0.35, blue: 0.95))
                                    .tracking(1)

                                Menu {
                                    ForEach(categories, id: \.id) { category in
                                        Button(category.name) {
                                            categoryId = category.id
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedCategoryName)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.65, green: 0.35, blue: 0.95))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.04))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                Text("DIFFICULTY")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.65, green: 0.35, blue: 0.95))
                                    .tracking(1)

                                Picker("Difficulty", selection: $difficulty) {
                                    ForEach(difficulties, id: \.self) { level in
                                        Text(level.capitalized).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                Text("QUESTIONS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.65, green: 0.35, blue: 0.95))
                                    .tracking(1)

                                Picker("Amount", selection: $amount) {
                                    ForEach(amounts, id: \.self) { n in
                                        Text("\(n)").tag(n)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                Text("TIMER PER QUESTION")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.65, green: 0.35, blue: 0.95))
                                    .tracking(1)

                                Picker("Timer", selection: $timerSeconds) {
                                    ForEach(timerOptions, id: \.self) { seconds in
                                        Text(timerLabel(seconds)).tag(seconds)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }

                NavigationLink(destination: QuizView()) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("START GAME")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.65, green: 0.35, blue: 0.95))
                    .cornerRadius(24)
                    .shadow(color: Color(red: 0.65, green: 0.35, blue: 0.95).opacity(0.30), radius: 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.08, blue: 0.10), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        QuizMenuView()
    }
}
