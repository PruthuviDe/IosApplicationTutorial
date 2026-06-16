import SwiftUI
import Combine

struct Card: Identifiable {
    let id = UUID()    
    var isLit = false 
}

struct LightItUpView: View {

    @State private var cards = [Card(), Card(), Card()] 
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var gameStarted = false

    // Countdown
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Lights up Timer
    let lightTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    var body: some View {

        if timeRemaining == 0 {

            VStack(spacing: 24) {

                Spacer()

                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Score: \(score)")
                    .font(.title)
                    .foregroundColor(.cyan)

                Button("Play Again") {
                    restartGame()
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cyan)
                .cornerRadius(12)
                .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)

        } else {

            VStack(spacing: 20) {

                HStack {
                    Text("Score: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(timeRemaining)s")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                if !gameStarted {
                    Text("Tap a lit card to begin!")
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {

                    ForEach(0..<cards.count, id: \.self) { index in

                        RoundedRectangle(cornerRadius: 12)
                            .fill(cards[index].isLit ? Color.yellow : Color(red: 0.15, green: 0.2, blue: 0.35))
                            .frame(height: 110)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .scaleEffect(cards[index].isLit ? 1.08 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: cards[index].isLit)
                            .onTapGesture {
                                tapCard(index: index)
                            }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.black, Color.cyan.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(.all, edges: .top)

            .onReceive(countdownTimer) { _ in
                if gameStarted && timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }

            .onReceive(lightTimer) { _ in
                if gameStarted {
                    for i in 0..<cards.count {
                        cards[i].isLit = false
                    }
                    let randomIndex = Int.random(in: 0..<cards.count)
                    cards[randomIndex].isLit = true
                }
            }
        }
    }

    func tapCard(index: Int) {

        if !gameStarted {
            gameStarted = true
        }

        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 60
        gameStarted = false
        cards = [Card(), Card(), Card()]
    }
}

#Preview {
    LightItUpView()
}
