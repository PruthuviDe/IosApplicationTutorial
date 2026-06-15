import SwiftUI
import Combine

struct ContentView: View {

    @State private var score = 0
    @State private var timeRemaining = 10

    // Countdown timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {

        if timeRemaining == 0 {

            VStack(spacing: 20) {

                Text("Game Over!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your Score: \(score)")
                    .font(.title)

                Button("Play Again") {
                    restartGame()
                }
                .font(.title2)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding()

        } else {

            VStack(spacing: 30) {

                Text("Tap Frenzy")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Score: \(score)")
                    .font(.title)

                Text("Time: \(timeRemaining)")
                    .font(.title2)
                    .foregroundColor(.orange)

                Button(action: {
                    score += 1
                }) {

                    Text("TAP!!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 250, height: 250)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()

            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 10
    }
}

#Preview {
    ContentView()
}
