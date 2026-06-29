import Foundation

// MARK: - View State Enum

// This enum describes what the quiz screen should show at any moment.
// Using an enum for this is cleaner than using multiple Bool flags like
// isLoading = true, isError = false, etc.
enum ViewState {
    case loading          // fetching questions from the API
    case loaded           // questions ready, game is running
    case failed(Error)    // something went wrong (no internet, bad response, etc.)
}

// MARK: - Quiz ViewModel

// ObservableObject is a protocol that lets SwiftUI watch this class for changes.
// When any @Published property changes, the View automatically redraws.
//
// WHY a class and not a struct?
//   - @StateObject in the View needs a class (reference type)
//   - ObservableObject only works with class
//
// WHY separate from the View?
//   - The View only handles what the user SEES
//   - The ViewModel handles the LOGIC (scoring, fetching, state changes)
//   - This makes the code easier to understand and test separately
class QuizViewModel: ObservableObject {

    // @Published means: "when this value changes, tell the View to redraw"
    @Published var viewState: ViewState = .loading
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0  // consecutive correct answers

    // The service that handles the actual network call
    private let service = QuizService()

    // MARK: - Computed Properties

    // The current question being shown (nil if index is out of range)
    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    // True when all 10 questions have been answered
    var isFinished: Bool {
        currentIndex >= questions.count && !questions.isEmpty
    }

    // MARK: - Load Questions

    // This is an async function — it can pause and wait for the network.
    // The View calls this using the .task modifier.
    func load() async {

        // Step 1: Tell the View we are loading
        await MainActor.run {
            viewState = .loading
        }

        do {
            // Step 2: Try to fetch questions (can throw an error)
            let fetched = try await service.fetchQuestions()

            // Step 3: We got questions — update on the main thread so the UI updates
            await MainActor.run {
                questions = fetched
                currentIndex = 0
                score = 0
                streak = 0
                viewState = .loaded
            }

        } catch {
            // Step 4: Something went wrong — show the error state with Retry option
            await MainActor.run {
                viewState = .failed(error)
            }
        }
    }

    // MARK: - Answer a Question

    // Called when the player taps an answer button
    func answer(_ selected: String) {

        guard let question = currentQuestion else { return }

        // Decode the correct answer to compare cleanly (removes HTML entities)
        let correct = question.decodedCorrectAnswer

        if selected == correct {
            // Correct answer
            streak += 1
            // Base points: 10, plus 5 bonus for each level of streak
            // streak 1 = 10 pts, streak 2 = 15 pts, streak 3 = 20 pts, etc.
            score += 10 + (streak * 5)
        } else {
            // Wrong answer — small penalty and streak resets
            streak = 0
            score = max(0, score - 5)  // max(0, ...) stops score going below zero
        }

        // Move to the next question
        currentIndex += 1
    }

    // MARK: - Play Again

    // Resets the game and fetches fresh questions
    func playAgain() {
        Task {
            await load()
        }
    }
}
