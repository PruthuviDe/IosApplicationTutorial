import SwiftUI

@main
struct IosApplicationTutorialApp: App {
    var body: some Scene {
        WindowGroup {
            ContentRoot()
        }
    }
}

struct ContentRoot: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }

            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .onAppear {
            LocationService.shared.requestPermission()
        }
    }
}
