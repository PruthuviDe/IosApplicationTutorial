import SwiftUI
import Combine

struct QuizView: View {

    @StateObject private var viewModel = QuizViewModel()

    @State private var flashColor: Color = .clear
    @State private var shakeOffset: CGFloat = 0

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
                    ResultView(
                        mode:      .quizRush,
                        score:     viewModel.score,
                        onRestart: { viewModel.playAgain() }
                    )
                    .onAppear { viewModel.saveSession() }
                } else {
                    questionView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.08, blue: 0.10), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(flashColor.ignoresSafeArea().allowsHitTesting(false))
        .toolbar(.hidden, for: .tabBar)

        .task {
            await viewModel.load()
        }
        .onReceive(countdown) { _ in
            if viewModel.isTimedOut {
                viewModel.handleTimeout()
                withAnimation(.easeIn(duration: 0.15)) {
                    flashColor = Color.red.opacity(0.20)
                }
                Task {
                    try? await Task.sleep(for: .seconds(0.5))
                    await MainActor.run {
                        withAnimation { flashColor = .clear }
                        viewModel.advanceAfterTimeout()
                    }
                }
            } else {
                viewModel.tickTimer()
            }
        }
    }

    var timerColor: Color {
        guard viewModel.timerSeconds > 0 else { return .clear }
        let ratio = Double(viewModel.timeRemaining) / Double(viewModel.timerSeconds)
        if ratio > 0.5 { return Color(red: 0.20, green: 0.83, blue: 0.52) } 
        if ratio > 0.25 { return Color(red: 0.95, green: 0.60, blue: 0.20) }
        return Color(red: 0.92, green: 0.26, blue: 0.35)
    }

    func answerBackground(for answer: String) -> Color {
        guard let reveal = viewModel.revealState else { return Color.white.opacity(0.04) }
        if answer == reveal.correct  { return Color.green.opacity(0.16) }
        if answer == reveal.selected { return Color.red.opacity(0.16) }
        return Color.white.opacity(0.02)
    }

    func answerBorderColor(for answer: String) -> Color {
        guard let reveal = viewModel.revealState else { return Color.white.opacity(0.18) }
        if answer == reveal.correct  { return Color.green.opacity(0.6) }
        if answer == reveal.selected { return Color.red.opacity(0.6) }
        return Color.white.opacity(0.08)
    }

    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color(red: 0.65, green: 0.35, blue: 0.95))
            Text("Loading Questions...")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    func errorView(error: Error) -> some View {
        VStack(spacing: 24) {

            Spacer()

            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.92, green: 0.26, blue: 0.35))

            Text("Could not load questions")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Check your internet connection and try again.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Retry") {
                Task { await viewModel.load() }
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.65, green: 0.35, blue: 0.95))
            .cornerRadius(12)
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    var questionView: some View {
        VStack(spacing: 20) {
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SCORE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text("\(viewModel.score)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 80, alignment: .leading)

                Spacer()

                VStack {
                    if viewModel.streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                            Text("\(viewModel.streak) streak")
                        }
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(8)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.top, 4)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("QUESTION")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text("\(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 80, alignment: .trailing)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            if viewModel.timerSeconds > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(timerColor)
                            .frame(width: geo.size.width * CGFloat(viewModel.timeRemaining) / CGFloat(viewModel.timerSeconds))
                            .animation(.linear(duration: 1.0), value: viewModel.timeRemaining)
                    }
                }
                .frame(height: 5)
                .padding(.horizontal, 24)
            }

            Spacer()

            Text(viewModel.currentQuestion?.decodedQuestion ?? "")
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .offset(x: shakeOffset)

            Spacer()
                .frame(maxHeight: 24)

            VStack(spacing: 12) {
                ForEach(viewModel.currentAnswers, id: \.self) { answer in
                    Button {
                        guard !viewModel.isAnswering else { return }

                        let isCorrect = viewModel.submitAnswer(answer)

                        if isCorrect {
                            withAnimation(.easeIn(duration: 0.15)) {
                                flashColor = Color.green.opacity(0.20)
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(0.5))
                                await MainActor.run {
                                    withAnimation { flashColor = .clear }
                                    shakeOffset = 0
                                    viewModel.advanceAfterAnswer(answer)
                                }
                            }
                        } else {
                            withAnimation(.easeIn(duration: 0.15)) {
                                flashColor = Color.red.opacity(0.20)
                            }
                            withAnimation(.easeInOut(duration: 0.06).repeatCount(5, autoreverses: true)) {
                                shakeOffset = 12
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(0.5))
                                await MainActor.run {
                                    withAnimation { flashColor = .clear }
                                    shakeOffset = 0
                                }
                                try? await Task.sleep(for: .seconds(1.0))
                                await MainActor.run {
                                    viewModel.advanceAfterAnswer(answer)
                                }
                            }
                        }
                    } label: {
                        Text(answer)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(answerBackground(for: answer))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(answerBorderColor(for: answer), lineWidth: viewModel.revealState != nil ? 1.5 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }

}

#Preview {
    QuizView()
}
