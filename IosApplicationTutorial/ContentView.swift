import SwiftUI
import Combine

struct ContentView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var highScore = 0

  
    @State private var comboMultiplier = 1
    @State private var lastTapTime = Date()


    @State private var buttonType = 0

    // Countdown timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Changes button colour
    let colourTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

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

   
                if buttonType == 0 {

                    Text("BLUE Normal (+\(comboMultiplier))")
                        .foregroundColor(.blue)

                } else if buttonType == 1 {

                    Text("GREEN Bonus (+3)")
                        .foregroundColor(.green)
                        .fontWeight(.bold)

                } else {

                    Text("GREY Trap (-1)")
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                }

                Button(action: {

     
                    let now = Date()

                    if now.timeIntervalSince(lastTapTime) < 0.5 {
                        comboMultiplier += 1
                    } else {
                        comboMultiplier = 1
                    }

                    lastTapTime = now


                    if buttonType == 1 {

                        score += 3

                    } else if buttonType == 2 {

                        score = max(0, score - 1)
                        comboMultiplier = 1

                    } else {

                        score += comboMultiplier
                    }

                }) {

                    Text("TAP!!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 250, height: 250)
                        .background(
                            buttonType == 1 ? Color.green :
                            buttonType == 2 ? Color.gray :
                            Color.blue
                        )
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

            .onReceive(colourTimer) { _ in
                buttonType = Int.random(in: 0...2)
            }
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        lastTapTime = Date()
        buttonType = 0
    }
}

#Preview {
    ContentView()
}
