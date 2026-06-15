//
//  ContentView.swift
//  IosApplicationTutorial
//
//  Created by Pruthuvi de Silva on 2026-06-15.
//

import SwiftUI
import Combine

struct ContentView: View {

    @State private var score = 0
    @State private var timeRemaining = 10

    // Countdown timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {

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
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
}

#Preview {
    ContentView()
}
