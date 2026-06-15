import SwiftUI
import Combine

struct ContentView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var highScore = 0

   
    @State private var comboMultiplier = 1
    @State private var lastTapTime = Date()

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

                Text("High Score: \(highScore)")
                    .font(.title2)
                    .foregroundColor(.orange)

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

 
                if comboMultiplier > 1 {
                    Text("×\(comboMultiplier) COMBO!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }

                Text("Time: \(timeRemaining)")
                    .font(.title2)
                    .foregroundColor(.orange)

                Button(action: {

    
                    let now = Date()

                    if now.timeIntervalSince(lastTapTime) < 0.5 {
                        comboMultiplier += 1
                    } else {
                        comboMultiplier = 1
                    }

                    lastTapTime = now

     
                    score += comboMultiplier

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

                if timeRemaining == 0 && score > highScore {
                    highScore = score
                }
            }
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        lastTapTime = Date()
    }
}

#Preview {
    ContentView()
}
