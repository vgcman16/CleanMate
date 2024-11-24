import Combine
import FirebaseAuth
import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                NavigationView {
                    SignInView()
                }
            }
        }
        .environmentObject(appState)
        .alert(
            "Session Expired",
            isPresented: $appState.showSessionExpired
        ) {
            Button("OK", role: .cancel) {
                appState.signOut()
            }
        } message: {
            Text("Please sign in again to continue.")
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            BookingsView()
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }
                .tag(Tab.bookings)
            
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "envelope")
                }
                .tag(Tab.messages)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
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
    @StateObject private var viewModel = BookingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.bookings) { booking in
                    BookingRow(booking: booking)
                }
            }
            .navigationTitle("My Bookings")
            .refreshable {
                await viewModel.fetchBookings()
            }
            .alert(
                "Error",
                isPresented: $viewModel.showError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .task {
            await viewModel.fetchBookings()
        }
    }
}

struct BookingRow: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(booking.service.name)
                .font(.headline)
            
            Text(booking.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Circle()
                    .fill(booking.status.color)
                    .frame(width: 8, height: 8)
                
                Text(booking.status.displayText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
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
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.user?.fullName ?? "")
                                .font(.headline)
                            Text(viewModel.user?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    NavigationLink(destination: PaymentMethodsView()) {
                        Label("Payment Methods", systemImage: "creditcard")
                    }
                    
                    NavigationLink(destination: AddressesView()) {
                        Label("Addresses", systemImage: "location")
                    }
                    
                    NavigationLink(destination: NotificationsView()) {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                Section {
                    Button(action: { appState.signOut() }) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert(
                "Error",
                isPresented: $viewModel.showError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .task {
            await viewModel.fetchProfile()
        }
    }
}
