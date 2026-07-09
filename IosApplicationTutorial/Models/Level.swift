import SwiftUI

struct DifficultySnapshot {
    let cardCount:      Int
    let litWindow:      Double
    let litCount:       Int
    let colorCount:     Int
    let sequenceLength: Int
    let accentColor:    Color

    static func compute(score: Int) -> DifficultySnapshot {

        let cardCount = min(3 + (score / 5), 12)

        let litWindow = max(1.5 - Double(score / 3) * 0.1, 0.4)

        let litCount = min(1 + (score / 15), 3)

        let colorCount = min(1 + (score / 10), 4)
        let rawSeq          = score < 30 ? 0 : min(1 + (score - 30) / 20, 4)
        let sequenceLength  = min(rawSeq, colorCount)

        let palette: [Color] = [
            Color(red: 0.20, green: 0.83, blue: 0.95),
            Color(red: 0.20, green: 0.83, blue: 0.52),
            Color(red: 0.95, green: 0.60, blue: 0.20),
            Color(red: 0.92, green: 0.26, blue: 0.35)
        ]
        let accent = palette[min(score / 10, palette.count - 1)]

        return DifficultySnapshot(
            cardCount:      cardCount,
            litWindow:      litWindow,
            litCount:       litCount,
            colorCount:     colorCount,
            sequenceLength: sequenceLength,
            accentColor:    accent
        )
    }
}
