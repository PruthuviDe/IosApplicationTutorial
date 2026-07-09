import SwiftUI
import MapKit

struct MapTab: View {

    @ObservedObject private var store = SessionStore.shared
    @State private var selectedSession: GameSession? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            ZStack {
                if store.sessions.isEmpty {
                    ZStack {
                        RadialGradient(
                            colors: [Color(red: 0.20, green: 0.65, blue: 0.95).opacity(0.35), Color(red: 0.08, green: 0.09, blue: 0.14)],
                            center: .top,
                            startRadius: 10,
                            endRadius: 400
                        )
                        .ignoresSafeArea()

                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.03))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1.5)
                                    )

                                Image(systemName: "map.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                            }

                            VStack(spacing: 6) {
                                Text("No locations yet")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Text("Play a game to drop pins on your gaming map.")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.40))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 48)
                            }
                        }
                    }
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.08, green: 0.09, blue: 0.14), Color(red: 0.12, green: 0.14, blue: 0.20)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                } else {
                    Map(position: $cameraPosition) {

                        UserAnnotation()

                        ForEach(store.sessions) { session in
                            Annotation(
                                session.mode.rawValue,
                                coordinate: CLLocationCoordinate2D(
                                    latitude:  session.latitude,
                                    longitude: session.longitude
                                )
                            ) {
                                Button {
                                    selectedSession = session
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(session.mode.accentColor)
                                            .frame(width: 36, height: 36)
                                            .shadow(color: session.mode.accentColor.opacity(0.50), radius: 6)

                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 36, height: 36)

                                        Image(systemName: session.mode.icon)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .mapStyle(.standard(pointsOfInterest: .all, showsTraffic: false))
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("Game Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedSession) { session in
                SessionDetailSheet(session: session)
            }
            .onAppear {
                LocationService.shared.requestPermission()
            }
        }
    }
}

struct SessionDetailSheet: View {

    let session: GameSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.white.opacity(0.20))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                ZStack {
                    Circle()
                        .fill(session.mode.accentColor.opacity(0.12))
                        .frame(width: 68, height: 68)
                        .overlay(
                            Circle()
                                .stroke(session.mode.accentColor.opacity(0.30), lineWidth: 2)
                        )

                    Image(systemName: session.mode.icon)
                        .font(.system(size: 28))
                        .foregroundColor(session.mode.accentColor)
                }

                Text(session.mode.rawValue)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    ScoreBadge(
                        label: "Score",
                        value: "\(session.score)",
                        icon: "star.fill",
                        color: .yellow
                    )
                    ScoreBadge(
                        label: "Date",
                        value: session.timestamp.formatted(date: .abbreviated, time: .omitted),
                        icon: "calendar",
                        color: .white.opacity(0.7)
                    )
                }
                .padding(.horizontal, 24)

                Button(action: { dismiss() }) {
                    Text("CLOSE")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.40))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.fraction(0.42)])
    }
}

#Preview {
    MapTab()
}
