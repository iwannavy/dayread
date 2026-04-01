import SwiftUI

enum AppTab: String, CaseIterable {
    case study = "학습"
    case review = "복습"
    case progress = "진도"
    case profile = "프로필"

    var icon: String {
        switch self {
        case .study: return "book.fill"
        case .review: return "arrow.counterclockwise"
        case .progress: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AuthService.self) private var authService

    @State private var selectedTab: AppTab = .study
    @State private var showLoginWall = false

    private var isGuest: Bool { authService.isGuest }

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tab.view
                    .tabItem {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(Color.dayreadGold)
        .onChange(of: selectedTab) { _, newTab in
            if isGuest && (newTab == .progress || newTab == .profile || newTab == .review) {
                showLoginWall = true
                selectedTab = .study
            }
        }
        .sheet(isPresented: $showLoginWall) {
            GuestLoginWallView()
        }
    }
}

extension AppTab {
    @ViewBuilder
    var view: some View {
        switch self {
        case .study:
            NavigationStack {
                LibraryView()
            }
        case .review:
            NavigationStack {
                ReviewTabView()
            }
        case .progress:
            NavigationStack {
                ProgressDashboardView()
            }
        case .profile:
            NavigationStack {
                ProfileView()
            }
        }
    }
}

