import Foundation

enum ViewState {
    case loading          
    case loaded           
    case failed(Error) 
}

class QuizViewModel: ObservableObject {

    @Published var viewState: ViewState = .loading
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0 

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

            let fetched = try await service.fetchQuestions()

            await MainActor.run {
                questions = fetched
                currentIndex = 0
                score = 0
                streak = 0
                viewState = .loaded
            }

        } catch {

            await MainActor.run {
                viewState = .failed(error)
            }
        }
    }

    func answer(_ selected: String) {

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
    }

    func playAgain() {
        Task {
            await load()
        }
    }
}
