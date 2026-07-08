import SwiftUI

// MARK: - DifficultySnapshot
/// Replaces the old fixed Level enum (L1–L4).
///
/// Every game parameter is calculated from the player's current score,
/// so difficulty increases smoothly and never hits a hard ceiling.
/// To tweak pacing, adjust the constants inside `compute(score:)`.
struct DifficultySnapshot {
    let cardCount:      Int       // how many cards are on screen
    let litWindow:      Double    // seconds a card stays lit before it counts as a miss
    let litCount:       Int       // how many cards light up per tick
    let colorCount:     Int       // how many distinct colours are available
    let sequenceLength: Int       // 0 = tap any lit card; 1+ = tap colours in order
    let accentColor:    Color     // visual theme colour that shifts with score

    // MARK: - The Algorithm
    /// All difficulty parameters are derived from `score`.
    /// No switch statements, no hardcoded level boundaries —
    /// just math that grows as long as the player keeps scoring.
    static func compute(score: Int) -> DifficultySnapshot {

        // Cards on screen: starts at 3, adds 1 every 5 points, caps at 12.
        let cardCount = min(3 + (score / 5), 12)

        // Lit window: starts at 1.5 s, gets 0.1 s faster every 3 points,
        // never drops below 0.4 s so the game stays physically possible.
        let litWindow = max(1.5 - Double(score / 3) * 0.1, 0.4)

        // Cards lit per tick: starts at 1, adds 1 every 15 points, max 3.
        let litCount = min(1 + (score / 15), 3)

        // Colours in play: starts at 1 (simple tap), adds a colour
        // every 10 points so colour-matching is introduced gradually, max 4.
        let colorCount = min(1 + (score / 10), 4)

        // Sequence mode: off until score 30, then length grows every 20 points, max 4.
        // (sequence length is capped by colorCount so colours are always unique)
        let rawSeq          = score < 30 ? 0 : min(1 + (score - 30) / 20, 4)
        let sequenceLength  = min(rawSeq, colorCount)

        // Accent colour shifts through the palette as score grows.
        let palette: [Color] = [
            Color(red: 0.20, green: 0.83, blue: 0.95),  // cyan
            Color(red: 0.20, green: 0.83, blue: 0.52),  // green
            Color(red: 0.95, green: 0.60, blue: 0.20),  // orange
            Color(red: 0.92, green: 0.26, blue: 0.35)   // red/hot
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
