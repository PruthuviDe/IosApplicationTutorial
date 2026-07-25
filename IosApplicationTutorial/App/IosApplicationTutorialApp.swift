import SwiftUI

@main
struct IosApplicationTutorialApp: App {
    var body: some Scene {
        WindowGroup {
            ContentRoot()
        }
    }
}

enum AppTab {
    case home, stats, map, settings
}

struct ContentRoot: View {
    @State private var currentTab: AppTab = .home
    @ObservedObject private var store = SessionStore.shared

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.05, green: 0.06, blue: 0.08)
                .ignoresSafeArea()

            Group {
                switch currentTab {
                case .home:
                    HomeTab()
                case .stats:
                    StatsTab()
                case .map:
                    MapTab()
                case .settings:
                    SettingsTab()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !store.isTabBarHidden {
                CustomTabBar(currentTab: $currentTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.isTabBarHidden)
        .onAppear {
            LocationService.shared.requestPermission()
        }
        .preferredColorScheme(.dark)
    }
}

struct CustomTabBar: View {
    @Binding var currentTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(tab: .home, icon: "gamecontroller.fill", title: "Games", currentTab: $currentTab)
            Spacer()
            TabBarButton(tab: .stats, icon: "chart.bar.fill", title: "Stats", currentTab: $currentTab)
            Spacer()
            TabBarButton(tab: .map, icon: "map.fill", title: "Map", currentTab: $currentTab)
            Spacer()
            TabBarButton(tab: .settings, icon: "gearshape.fill", title: "Settings", currentTab: $currentTab)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 0)
    }
}

struct TabBarButton: View {
    let tab: AppTab
    let icon: String
    let title: String
    @Binding var currentTab: AppTab

    var isSelected: Bool { currentTab == tab }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? .cyan : .white.opacity(0.5))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(isSelected ? Color.cyan.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
