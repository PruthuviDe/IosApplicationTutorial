import SwiftUI
import MapKit

struct MapTab: View {


    @ObservedObject private var store = SessionStore.shared
    @State private var selectedSession: GameSession? = nil
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
                            
                            ForEach(filteredSessions) { session in
                                let jitterLat = Double(session.id.uuidString.hashValue % 100) / 150000.0
                                let jitterLon = Double((session.id.uuidString.hashValue / 100) % 100) / 150000.0
                                
                                Annotation(
                                    "",
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: session.latitude + jitterLat,
                                        longitude: session.longitude + jitterLon
                                    ),
                                    anchor: .bottom
                                ) {
                                    VStack(spacing: 0) {
                                        if selectedSession?.id == session.id {
                                            VStack(spacing: 0) {
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
                                                withAnimation { selectedSession = nil }
                                            }
                                            .zIndex(1)
                                        }
                                        
                                        Button {
                                            withAnimation {
                                                selectedSession = session
                                            }
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(session.mode.accentColor)
                                                    .frame(width: 36, height: 36)
                                                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                                                
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedSession?.id == session.id ? 2.5 : 1.5)
                                                    .frame(width: 36, height: 36)
                                                
                                                Image(session.mode.imageName)
                                                     .resizable()
                                                     .aspectRatio(contentMode: .fill)
                                                     .frame(width: 33, height: 33)
                                                     .clipShape(Circle())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .mapStyle(.standard(pointsOfInterest: .all, showsTraffic: false))
                        .mapControls {
                            MapCompass()
                            MapScaleView()
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedSession = nil
                            }
                        }
                        
                        HStack(spacing: 4) {
                            ForEach(gamesList, id: \.self) { game in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedGame = game
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
