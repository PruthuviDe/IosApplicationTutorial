import Foundation
import Combine
import SwiftUI

enum ViewState {
    case loading          
    case loaded           
    case failed(Error) 
}

struct RevealState {
    let selected: String
    let correct:  String
}

class QuizViewModel: ObservableObject {

    @Published var viewState: ViewState = .loading
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0

    @Published var currentAnswers: [String] = []
    @Published var timeRemaining: Int = 0
    @Published var isAnswering: Bool = false
    @Published var revealState: RevealState? = nil

    @AppStorage("quizCategoryId") private var categoryId = 0
    @AppStorage("quizDifficulty") private var difficulty = "any"
    @AppStorage("quizAmount") private var amount = 10
    @AppStorage("quizTimerSeconds") private(set) var timerSeconds = 0

    private let service = QuizService()

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var isFinished: Bool {
        currentIndex >= questions.count && !questions.isEmpty
    }

    func load() async {

        await MainActor.run {
            viewState = .loading
        }

        do {

            let fetched = try await service.fetchQuestions(
                categoryId: categoryId,
                difficulty: difficulty,
                amount: amount
            )

            await MainActor.run {
                questions = fetched
                currentIndex = 0
                score = 0
                streak = 0
                isAnswering = false
                revealState = nil
                currentAnswers = fetched.first?.decodedShuffledAnswers() ?? []
                timeRemaining = timerSeconds
                viewState = .loaded
            }

        } catch {

            await MainActor.run {
                viewState = .failed(error)
            }
        }
    }

    func refreshAnswers() {
        currentAnswers = currentQuestion?.decodedShuffledAnswers() ?? []
        timeRemaining = timerSeconds
        revealState = nil
    }

    func submitAnswer(_ selected: String) -> Bool {
        guard let question = currentQuestion else { return false }
        isAnswering = true

        let correct = question.decodedCorrectAnswer
        let isCorrect = selected == correct

        if !isCorrect {
            revealState = RevealState(selected: selected, correct: correct)
        }

        return isCorrect
    }

    func advanceAfterAnswer(_ selected: String) {
        guard let question = currentQuestion else { return }
        let correct = question.decodedCorrectAnswer

        if selected == correct {
            streak += 1
            score += 10 + (streak * 5)
        } else {
            streak = 0
            score = max(0, score - 5)
        }

        currentIndex += 1
        isAnswering = false

        if !isFinished {
            refreshAnswers()
        }
    }

    func handleTimeout() {
        isAnswering = true
    }

    func advanceAfterTimeout() {
        streak = 0
        score = max(0, score - 5)
        currentIndex += 1
        isAnswering = false

        if !isFinished {
            refreshAnswers()
        }
    }

    func tickTimer() {
        guard timerSeconds > 0,
              !isAnswering,
              case .loaded = viewState,
              !isFinished else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
        }
    }

    var isTimedOut: Bool {
        timerSeconds > 0 && timeRemaining <= 0 && !isAnswering
    }

    func saveSession() {
        let loc = LocationService.shared.coordinate
        SessionStore.shared.save(session: GameSession(
            mode:      .quizRush,
            score:     score,
            latitude:  loc.latitude,
            longitude: loc.longitude
        ))
    }

    func playAgain() {
        Task {
            await load()
        }
    }
}
