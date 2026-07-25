import Foundation

struct QuizService {

    private let baseURL = "https://opentdb.com/api.php?amount=10&type=multiple&encode=url3986"

    func fetchQuestions(categoryId: Int, difficulty: String, amount: Int) async throws -> [QuizQuestion] {

        var urlString = baseURL
        urlString = urlString.replacingOccurrences(of: "amount=10", with: "amount=\(amount)")
        if categoryId != 0     { urlString += "&category=\(categoryId)" }
        if difficulty != "any" { urlString += "&difficulty=\(difficulty)" }

        let url = URL(string: urlString)!

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(QuizResponse.self, from: data)
        return decoded.results
    }
}
