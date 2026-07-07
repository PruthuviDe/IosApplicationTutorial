import SwiftUI

// MARK: - Card Model
/// A single card in the Light It Up grid.
struct Card: Identifiable {
    let id = UUID()
    var isLit = false
}
