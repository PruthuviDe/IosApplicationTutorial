import Foundation

// QuizService is responsible for one thing only:
// fetching questions from the Open Trivia DB API.
//
// Keeping network code here (instead of in the ViewModel or View)
// means if the URL ever changes, we only update this one file.

struct QuizService {

    // The API URL — stored in one place so it's easy to find and change
    // amount=10  → fetch 10 questions per round
    // type=multiple → multiple choice questions only (4 answers)
    private let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    // async throws means:
    //   async  → this function can pause and wait for the network
    //   throws → it can fail and pass the error back to the caller
    func fetchQuestions() async throws -> [QuizQuestion] {

        // URLSession.shared.data pauses here until the network responds
        // The underscore _ ignores the HTTP response headers we don't need
        let (data, _) = try await URLSession.shared.data(from: url)

        // JSONDecoder maps the JSON fields to our QuizResponse struct
        let decoded = try JSONDecoder().decode(QuizResponse.self, from: data)

        return decoded.results
    }
}
