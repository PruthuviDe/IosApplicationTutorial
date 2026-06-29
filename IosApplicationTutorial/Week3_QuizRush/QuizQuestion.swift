import Foundation

// MARK: - API Response Wrapper

// This struct matches the top-level JSON object returned by the API:
// { "response_code": 0, "results": [ ... ] }
struct QuizResponse: Codable {
    let results: [QuizQuestion]
}

// MARK: - Question Model

// This struct matches one question object inside "results"
struct QuizQuestion: Codable {

    let question: String           // the trivia question text
    let correctAnswer: String      // the one correct answer
    let incorrectAnswers: [String] // three wrong answers

    // CodingKeys tells Swift how to map the API's snake_case names
    // to our Swift camelCase property names
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer   = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    // Combine the correct answer with the 3 wrong ones,
    // then shuffle so the correct button is in a random position
    var shuffledAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }

    // The API uses default encoding which returns HTML entities
    // e.g. &quot; instead of "  and  &#039; instead of '
    // This helper converts them back to readable text
    var decodedQuestion: String {
        question.htmlDecoded
    }

    var decodedCorrectAnswer: String {
        correctAnswer.htmlDecoded
    }

    func decodedShuffledAnswers() -> [String] {
        shuffledAnswers.map { $0.htmlDecoded }
    }
}

// MARK: - HTML Decoding Helper

// A String extension adds a new property to the built-in String type
// We use it to clean up HTML entities from the API response
extension String {
    var htmlDecoded: String {
        var result = self
        let entities: [String: String] = [
            "&quot;"  : "\"",
            "&#039;"  : "'",
            "&amp;"   : "&",
            "&lt;"    : "<",
            "&gt;"    : ">",
            "&apos;"  : "'"
        ]
        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        return result
    }
}
