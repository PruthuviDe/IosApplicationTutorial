import Foundation

struct QuizService {

    private let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    func fetchQuestions() async throws -> [QuizQuestion] {

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded = try JSONDecoder().decode(QuizResponse.self, from: data)

        return decoded.results
    }
}
