import SwiftUI
import MapKit

struct MapTab: View {

    @ObservedObject private var store = SessionStore.shared
    @State private var selectedSession: GameSession? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                if store.sessions.isEmpty {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.2))
                        Text("No locations yet")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.4))
                        Text("Play a game to drop a pin on the map.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.3))
                    }
                } else {
                    Map {
                        ForEach(store.sessions) { session in
                            Annotation(
                                session.mode.rawValue,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: session.latitude,
                                    longitude: session.longitude
                                )
                            ) {
                                Button {
                                    selectedSession = session
                                } label: {
                                    Image(systemName: session.mode.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(session.mode.accentColor)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("Map of Games")
            .navigationBarTitleDisplayMode(.inline)
            // Session detail sheet — appears when a pin is tapped
            .sheet(item: $selectedSession) { session in
                SessionDetailSheet(session: session)
            }
        }
    }
}

struct SessionDetailSheet: View {

    let session: GameSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Image(systemName: session.mode.icon)
                .font(.system(size: 40))
                .foregroundColor(session.mode.accentColor)

            Text(session.mode.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 20) {
                ScoreBadge(label: "Score", value: "\(session.score)", icon: "star.fill", color: .yellow)
                ScoreBadge(label: "Date", value: session.timestamp.formatted(date: .abbreviated, time: .omitted), icon: "calendar", color: .white)
            }

            Button("Close") { dismiss() }
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .presentationDetents([.fraction(0.35)])
    }
}

#Preview {
    MapTab()
}
