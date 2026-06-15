//
//  ContentView.swift
//  IosApplicationTutorial
//
//  Created by Pruthuvi de Silva on 2026-06-15.
//

import SwiftUI

struct ContentView: View {
    
    @State private var score = 0
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            Text("Tap Frenzy")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Score: \(score)")
                .font(.title)
            
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
    }
}

#Preview {
    ContentView()
}
