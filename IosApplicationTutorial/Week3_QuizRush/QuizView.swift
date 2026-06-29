import SwiftUI

struct QuizView: View {

    @StateObject private var viewModel = QuizViewModel()
    @State private var currentAnswers: [String] = []
    @AppStorage("quizRushHighScore") private var highScore = 0

    // --- Animation state ---
    // flashColor: briefly colours the whole screen green (correct) or red (wrong)
    @State private var flashColor: Color = .clear
    // shakeOffset: moves the question text left/right on a wrong answer
    @State private var shakeOffset: CGFloat = 0
    // isAnswering: locks buttons so the player can't tap twice during feedback
    @State private var isAnswering = false

    var body: some View {

        Group {
            switch viewModel.viewState {

            case .loading:
                loadingView

            case .failed(let error):
                errorView(error: error)

            case .loaded:
                if viewModel.isFinished {
                    resultsView
                } else {
                    questionView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        // Full-screen colour flash — appears for 0.5s then fades away
        .overlay(flashColor.ignoresSafeArea().allowsHitTesting(false))

        .task {
            await viewModel.load()
            currentAnswers = viewModel.currentQuestion?.decodedShuffledAnswers() ?? []
        }
        .onChange(of: viewModel.currentIndex) {
            currentAnswers = viewModel.currentQuestion?.decodedShuffledAnswers() ?? []
        }
    }

    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.purple)
            Text("Loading Questions...")
                .foregroundColor(.white.opacity(0.6))
        }
    }

    func errorView(error: Error) -> some View {
        VStack(spacing: 24) {

            Spacer()

            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Could not load questions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Check your internet connection and try again.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Retry") {
                Task { await viewModel.load() }
            }
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .cornerRadius(12)
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    var questionView: some View {
        VStack(spacing: 20) {
            HStack {

                Text("\(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.headline)
                    .foregroundColor(.purple)

                Spacer()

                if viewModel.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("x\(viewModel.streak)")
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

                Text("Score: \(viewModel.score)")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)

            Spacer()

            Text(viewModel.currentQuestion?.decodedQuestion ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                // Shake applied here — moves left/right on wrong answer
                .offset(x: shakeOffset)

            Spacer()
            VStack(spacing: 12) {
                ForEach(currentAnswers, id: \.self) { answer in
                    Button {
                        // Ignore taps while feedback animation is running
                        guard !isAnswering else { return }
                        isAnswering = true

                        let correct = viewModel.currentQuestion?.decodedCorrectAnswer
                        let isCorrect = answer == correct

                        if isCorrect {
                            // Green flash for correct answer
                            withAnimation(.easeIn(duration: 0.15)) {
                                flashColor = Color.green.opacity(0.35)
                            }
                        } else {
                            // Red flash + left-right shake for wrong answer
                            withAnimation(.easeIn(duration: 0.15)) {
                                flashColor = Color.red.opacity(0.35)
                            }
                            withAnimation(.easeInOut(duration: 0.06).repeatCount(5, autoreverses: true)) {
                                shakeOffset = 12
                            }
                        }

                        // Wait 0.5s so the player can see the feedback,
                        // then advance to the next question
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation { flashColor = .clear }
                            shakeOffset = 0
                            viewModel.answer(answer)
                            isAnswering = false
                        }
                    } label: {
                        Text(answer)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.6), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    var resultsView: some View {
        VStack(spacing: 24) {

            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Quiz Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Final Score")
                .foregroundColor(.white.opacity(0.6))

            Text("\(viewModel.score)")
                .font(.system(size: 64, weight: .heavy))
                .foregroundColor(.purple)

            Text("Best: \(highScore)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.5))

            Button("Play Again") {
                viewModel.playAgain()
            }
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .cornerRadius(12)
            .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            if viewModel.score > highScore {
                highScore = viewModel.score
            }
        }
    }
}

#Preview {
    QuizView()
}
