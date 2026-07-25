import SwiftUI
import MapKit

struct LocationCluster: Identifiable, Equatable {
    let id: String
    let latitude: Double
    let longitude: Double
    let sessions: [GameSession]

    var count: Int { sessions.count }
    
    var latestSession: GameSession {
        sessions.max(by: { $0.timestamp < $1.timestamp }) ?? sessions[0]
    }
    
    var bestScore: Int {
        sessions.map(\.score).max() ?? 0
    }

    static func == (lhs: LocationCluster, rhs: LocationCluster) -> Bool {
        lhs.id == rhs.id && lhs.sessions.count == rhs.sessions.count
    }
}

struct MapTab: View {

    @ObservedObject private var store = SessionStore.shared
    @State private var selectedCluster: LocationCluster? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedGame: String = "All"

    var gamesList: [String] {
        var list = ["All"]
        list.append(contentsOf: GameMode.allCases.map { $0.rawValue })
        return list
    }

    private var validSessions: [GameSession] {
        store.sessions.filter { $0.latitude != 0 || $0.longitude != 0 }
    }

    private var filteredSessions: [GameSession] {
        if selectedGame == "All" {
            return validSessions
        }
        return validSessions.filter { $0.mode.rawValue == selectedGame }
    }

    private var locationClusters: [LocationCluster] {
        var groups: [String: (lat: Double, lon: Double, sessions: [GameSession])] = [:]

        for session in filteredSessions {
            let key = String(format: "%.3f_%.3f", session.latitude, session.longitude)
            if groups[key] == nil {
                groups[key] = (session.latitude, session.longitude, [session])
            } else {
                groups[key]!.sessions.append(session)
            }
        }

        return groups.map { (key, value) in
            LocationCluster(
                id: key,
                latitude: value.lat,
                longitude: value.lon,
                sessions: value.sessions.sorted(by: { $0.timestamp > $1.timestamp })
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if validSessions.isEmpty {
                    ZStack {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 100, height: 100)
                                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))

                                Image(systemName: "map.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                            }

                            VStack(spacing: 6) {
                                Text("No locations yet")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text("Play a game to drop pins on your gaming map.")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 48)
                            }
                        }
                    }

                } else {
                    ZStack(alignment: .top) {
                        Map(position: $cameraPosition) {
                            UserAnnotation()

                            ForEach(locationClusters) { cluster in
                                Annotation(
                                    "",
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: cluster.latitude,
                                        longitude: cluster.longitude
                                    ),
                                    anchor: .bottom
                                ) {
                                    VStack(spacing: 0) {
                                        if selectedCluster?.id == cluster.id {
                                            VStack(spacing: 0) {
                                                if cluster.count == 1 {
                                                    let session = cluster.latestSession
                                                    HStack(spacing: 12) {
                                                        Image(session.mode.imageName)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 38, height: 38)
                                                            .cornerRadius(8)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                            )

                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(session.mode.rawValue)
                                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                                .foregroundColor(.white)

                                                            HStack(spacing: 10) {
                                                                HStack(alignment: .firstTextBaseline, spacing: 3) {
                                                                    Text("\(session.score)")
                                                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                                                        .foregroundColor(.white)
                                                                    Text("PTS")
                                                                        .font(.system(size: 8, weight: .heavy, design: .rounded))
                                                                        .foregroundColor(session.mode.accentColor)
                                                                }

                                                                HStack(spacing: 3) {
                                                                    Image(systemName: "clock.fill")
                                                                        .font(.system(size: 8))
                                                                        .foregroundColor(.secondary)
                                                                    Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                                                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                                                                        .foregroundColor(.secondary)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 10)
                                                    .background(Color(red: 0.11, green: 0.11, blue: 0.12))
                                                    .cornerRadius(12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                    )
                                                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                                                } else {
                                                    VStack(alignment: .leading, spacing: 8) {
                                                        HStack(spacing: 6) {
                                                            Text("LOCATION")
                                                                .font(.system(size: 10, weight: .bold))
                                                                .foregroundColor(.secondary)
                                                                .tracking(1)

                                                            Text("\(cluster.count) GAMES")
                                                                .font(.system(size: 9, weight: .black, design: .rounded))
                                                                .foregroundColor(.white)
                                                                .padding(.horizontal, 6)
                                                                .padding(.vertical, 2)
                                                                .background(Color.red)
                                                                .clipShape(Capsule())

                                                            Spacer(minLength: 12)

                                                            Text("BEST: \(cluster.bestScore)")
                                                                .font(.system(size: 10, weight: .black, design: .rounded))
                                                                .foregroundColor(cluster.latestSession.mode.accentColor)
                                                        }

                                                        ScrollView(showsIndicators: true) {
                                                            VStack(spacing: 6) {
                                                                ForEach(cluster.sessions) { session in
                                                                    HStack(spacing: 8) {
                                                                        Image(session.mode.imageName)
                                                                            .resizable()
                                                                            .aspectRatio(contentMode: .fill)
                                                                            .frame(width: 26, height: 26)
                                                                            .cornerRadius(6)

                                                                        VStack(alignment: .leading, spacing: 1) {
                                                                            Text(session.mode.rawValue)
                                                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                                                .foregroundColor(.white)
                                                                            Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                                                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                                                                .foregroundColor(.secondary)
                                                                        }

                                                                        Spacer(minLength: 12)

                                                                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                                                                            Text("\(session.score)")
                                                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                                                .foregroundColor(.white)
                                                                            Text("PTS")
                                                                                .font(.system(size: 7, weight: .heavy, design: .rounded))
                                                                                .foregroundColor(session.mode.accentColor)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        .frame(maxHeight: 160)
                                                    }
                                                    .padding(12)
                                                    .frame(width: 250)
                                                    .background(Color(red: 0.11, green: 0.11, blue: 0.12))
                                                    .cornerRadius(14)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                    )
                                                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                                                }

                                                Path { path in
                                                    path.move(to: CGPoint(x: 0, y: 0))
                                                    path.addLine(to: CGPoint(x: 12, y: 0))
                                                    path.addLine(to: CGPoint(x: 6, y: 6))
                                                    path.closeSubpath()
                                                }
                                                .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                                                .frame(width: 12, height: 6)
                                                .padding(.bottom, 2)
                                            }
                                            .onTapGesture {
                                                withAnimation(.spring()) { selectedCluster = nil }
                                            }
                                            .zIndex(1)
                                        }

                                        Button {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                if selectedCluster?.id == cluster.id {
                                                    selectedCluster = nil
                                                } else {
                                                    selectedCluster = cluster
                                                }
                                            }
                                        } label: {
                                            ZStack(alignment: .topTrailing) {
                                                let isSelected = selectedCluster?.id == cluster.id
                                                let mainMode = cluster.latestSession.mode
                                                
                                                ZStack {
                                                    Circle()
                                                        .fill(mainMode.accentColor)
                                                        .frame(width: 40, height: 40)
                                                        .shadow(color: isSelected ? mainMode.accentColor.opacity(0.6) : .black.opacity(0.3), radius: isSelected ? 8 : 4, y: 2)

                                                    Circle()
                                                        .stroke(isSelected ? Color.white : Color.white.opacity(0.8), lineWidth: isSelected ? 3 : 1.5)
                                                        .frame(width: 40, height: 40)

                                                    Image(mainMode.imageName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 36, height: 36)
                                                        .clipShape(Circle())
                                                }
                                                .scaleEffect(isSelected ? 1.15 : 1.0)

                                                if cluster.count > 1 {
                                                    Text("\(cluster.count)")
                                                        .font(.system(size: 11, weight: .black, design: .rounded))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Color.red)
                                                        .clipShape(Capsule())
                                                        .overlay(
                                                            Capsule().stroke(Color.white, lineWidth: 1.5)
                                                        )
                                                        .offset(x: 8, y: -6)
                                                        .shadow(color: .black.opacity(0.4), radius: 3)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: false))
                        .mapControls {
                            MapCompass()
                            MapScaleView()
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedCluster = nil
                            }
                        }

                        HStack(spacing: 4) {
                            ForEach(gamesList, id: \.self) { game in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedGame = game
                                        selectedCluster = nil
                                    }
                                }) {
                                    Text(game)
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .foregroundColor(selectedGame == game ? .black : .white.opacity(0.8))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(selectedGame == game ? Color.white : Color.clear)
                                        )
                                }
                            }
                        }
                        .padding(4)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.16).opacity(0.95))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 72)

                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        if let coord = LocationService.shared.currentLocation {
                                            cameraPosition = .region(MKCoordinateRegion(
                                                center: coord,
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            ))
                                        } else {
                                            cameraPosition = .userLocation(fallback: .automatic)
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.15, green: 0.15, blue: 0.16).opacity(0.95))
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                                            )
                                            .shadow(color: .black.opacity(0.3), radius: 6, y: 3)

                                        Image(systemName: "location.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 120)
                            }
                        }
                    }
                    .ignoresSafeArea()
                }
            }
            .onAppear {
                LocationService.shared.requestPermission()
                SessionStore.shared.isTabBarHidden = false
            }
        }
    }
}

#Preview {
    MapTab()
}
