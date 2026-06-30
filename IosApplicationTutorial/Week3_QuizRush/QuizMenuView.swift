import SwiftUI

struct QuizMenuView: View {

    // Settings saved to device storage — same keys QuizViewModel will read
    @AppStorage("quizCategoryId") private var categoryId = 0
    @AppStorage("quizDifficulty") private var difficulty = "any"

    // Curated list of categories from Open Trivia DB
    // id: 0 means "Any" — no category param in the URL
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

    var body: some View {

        VStack(spacing: 32) {

            Spacer()

            // --- Title ---
            VStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)

                Text("Quiz Rush")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("10 questions · tap fast · build your streak")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // --- Settings Card ---
            VStack(spacing: 0) {

                // Category picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("CATEGORY")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)

                    // Picker scrolls through all categories
                    Picker("Category", selection: $categoryId) {
                        ForEach(categories, id: \.id) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                }
                .padding()
                .background(Color.white.opacity(0.07))
                .cornerRadius(12)

                Divider().background(Color.clear).padding(.vertical, 12)

                // Difficulty picker (segmented)
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
            }
            .padding(.horizontal, 24)

            Spacer()

            // --- Start Game Button ---
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
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        QuizMenuView()
    }
}
