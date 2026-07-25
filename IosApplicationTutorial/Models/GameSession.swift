import Foundation

struct GameSession: Identifiable, Codable {

    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    init(mode: GameMode, score: Int, latitude: Double = 0.0, longitude: Double = 0.0) {
        self.id        = UUID()
        self.mode      = mode
        self.score     = score
        self.timestamp = Date()
        self.latitude  = latitude
        self.longitude = longitude
    }
}
