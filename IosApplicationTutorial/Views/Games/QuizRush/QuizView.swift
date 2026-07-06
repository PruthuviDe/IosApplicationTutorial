import SwiftUI
import Combine

struct QuizView: View {

    @StateObject private var viewModel = QuizViewModel()
    @State private var currentAnswers: [String] = []
    @AppStorage("quizRushHighScore") private var highScore = 0
    @AppStorage("quizTimerSeconds") private var timerSeconds = 0

    @State private var flashColor: Color = .clear
    @State private var shakeOffset: CGFloat = 0
    @State private var isAnswering = false
    @State private var timeRemaining: Int = 0

    @State private var revealAnswers: (selected: String, correct: String)? = nil
    
    private let countdown = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .overlay(flashColor.ignoresSafeArea().allowsHitTesting(false))

        .task {
            await viewModel.load()
            currentAnswers = viewModel.currentQuestion?.decodedShuffledAnswers() ?? []
            timeRemaining = timerSeconds
        }
        .onChange(of: viewModel.currentIndex) {
            currentAnswers = viewModel.currentQuestion?.decodedShuffledAnswers() ?? []
            timeRemaining = timerSeconds
            revealAnswers = nil
        }
        .onReceive(countdown) { _ in
            guard timerSeconds > 0,
                  !isAnswering,
                  case .loaded = viewModel.viewState,
                  !viewModel.isFinished else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isAnswering = true
                withAnimation(.easeIn(duration: 0.15)) {
                    flashColor = Color.red.opacity(0.35)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { flashColor = .clear }
                    viewModel.answer("")
                    isAnswering = false
                }
            }
        }
    }

    var timerColor: Color {
        guard timerSeconds > 0 else { return .clear }
        let ratio = Double(timeRemaining) / Double(timerSeconds)
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .orange }
        return .red
    }

    func answerBackground(for answer: String) -> Color {
        guard let reveal = revealAnswers else { return Color.white.opacity(0.1) }
        if answer == reveal.correct  { return Color.green.opacity(0.25) }
        if answer == reveal.selected { return Color.red.opacity(0.25) }
        return Color.white.opacity(0.04)
    }

    func answerBorderColor(for answer: String) -> Color {
        guard let reveal = revealAnswers else { return Color.purple.opacity(0.6) }
        if answer == reveal.correct  { return Color.green }
        if answer == reveal.selected { return Color.red }
        return Color.gray.opacity(0.3)
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

            if timerSeconds > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(timerColor)
                            .frame(width: geo.size.width * CGFloat(timeRemaining) / CGFloat(timerSeconds))
                            .animation(.linear(duration: 1), value: timeRemaining)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 24)
            }

            Spacer()

            Text(viewModel.currentQuestion?.decodedQuestion ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .offset(x: shakeOffset)

            Spacer()
            VStack(spacing: 12) {
                ForEach(currentAnswers, id: \.self) { answer in
                    Button {
                        guard !isAnswering else { return }
                        isAnswering = true

                        let correct = viewModel.currentQuestion?.decodedCorrectAnswer
                        let isCorrect = answer == correct

                        if isCorrect {
                            withAnimation(.easeIn(duration: 0.15)) {
                                flashColor = Color.green.opacity(0.35)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation { flashColor = .clear }
                                shakeOffset = 0
                                viewModel.answer(answer)
                                isAnswering = false
                            }
                        } else {
                            withAnimation(.easeIn(duration: 0.15)) {
                                flashColor = Color.red.opacity(0.35)
                            }
                            withAnimation(.easeInOut(duration: 0.06).repeatCount(5, autoreverses: true)) {
                                shakeOffset = 12
                            }
                            revealAnswers = (selected: answer, correct: correct ?? "")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation { flashColor = .clear }
                                shakeOffset = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                viewModel.answer(answer)
                                isAnswering = false
                            }
                        }
                    } label: {
                        Text(answer)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(answerBackground(for: answer))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(answerBorderColor(for: answer), lineWidth: revealAnswers != nil ? 2 : 1)
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
