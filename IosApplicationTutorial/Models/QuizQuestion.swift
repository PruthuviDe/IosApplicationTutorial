import Foundation


struct QuizResponse: Codable {
    let results: [QuizQuestion]
}


struct QuizQuestion: Codable {

    let question: String           
    let correctAnswer: String      
    let incorrectAnswers: [String]


    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer   = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    var shuffledAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }

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

extension String {
    var htmlDecoded: String {
        return self.removingPercentEncoding ?? self
    }
}
