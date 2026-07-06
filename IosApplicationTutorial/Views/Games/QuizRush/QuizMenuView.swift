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

        VStack(spacing: 0) {

            ScrollView {
                VStack(spacing: 24) {

                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)

                        Text("Quiz Rush")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("\(amount) questions · tap fast · build your streak")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)

                            Menu {
                                ForEach(categories, id: \.id) { category in
                                    Button(category.name) {
                                        categoryId = category.id
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCategoryName)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                }
                                .padding()
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(12)

                        Divider().background(Color.clear).padding(.vertical, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("DIFFICULTY")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)

                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(difficulties, id: \.self) { level in
                                    Text(level.capitalized).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(12)

                        Divider().background(Color.clear).padding(.vertical, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("QUESTIONS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)

                            Picker("Amount", selection: $amount) {
                                ForEach(amounts, id: \.self) { n in
                                    Text("\(n)").tag(n)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(12)

                        Divider().background(Color.clear).padding(.vertical, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("TIMER PER QUESTION")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)

                            Picker("Timer", selection: $timerSeconds) {
                                ForEach(timerOptions, id: \.self) { seconds in
                                    Text(timerLabel(seconds)).tag(seconds)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }

            NavigationLink(destination: QuizView()) {
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        QuizMenuView()
    }
}
