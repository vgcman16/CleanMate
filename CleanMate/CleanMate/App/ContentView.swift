import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                SignInView()
            }
        }
        .animation(.default, value: appState.isAuthenticated)
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.title,
                          systemImage: Tab.home.rawValue)
                }
                .tag(Tab.home)
            
            BookingsView()
                .tabItem {
                    Label(Tab.bookings.title,
                          systemImage: Tab.bookings.rawValue)
                }
                .tag(Tab.bookings)
            
            MessagesView()
                .tabItem {
                    Label(Tab.messages.title,
                          systemImage: Tab.messages.rawValue)
                }
                .tag(Tab.messages)
            
            ProfileView()
                .tabItem {
                    Label(Tab.profile.title,
                          systemImage: Tab.profile.rawValue)
                }
                .tag(Tab.profile)
        }
    }
}

// Placeholder Views
struct HomeView: View {
    var body: some View {
        NavigationView {
            Text("Home View")
                .navigationTitle("Home")
        }
    }
}

struct BookingsView: View {
    var body: some View {
        NavigationView {
            Text("Bookings View")
                .navigationTitle("Bookings")
        }
    }
}

struct MessagesView: View {
    var body: some View {
        NavigationView {
            Text("Messages View")
                .navigationTitle("Messages")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Profile View")
                .navigationTitle("Profile")
        }
    }
}
