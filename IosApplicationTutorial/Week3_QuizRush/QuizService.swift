import Foundation

struct QuizService {

    // Base URL — category and difficulty are added only when selected
    private let baseURL = "https://opentdb.com/api.php?amount=10&type=multiple"

    // categoryId: 0 = Any (no param added)
    // difficulty: "any" = Any (no param added)
    func fetchQuestions(categoryId: Int, difficulty: String) async throws -> [QuizQuestion] {

        // Build URL dynamically based on user's settings
        var urlString = baseURL
        if categoryId != 0     { urlString += "&category=\(categoryId)" }
        if difficulty != "any" { urlString += "&difficulty=\(difficulty)" }

        let url = URL(string: urlString)!

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(QuizResponse.self, from: data)
        return decoded.results
    }
}
