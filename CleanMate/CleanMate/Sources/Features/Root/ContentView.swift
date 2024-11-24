import SwiftUI

struct ContentView: View {
    @EnvironmentObject
    private var appState: AppState
    
    @EnvironmentObject
    private var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView(selection: $appState.currentTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(AppState.Tab.home)
                    
                    BookingsView()
                        .tabItem {
                            Label("Bookings", systemImage: "calendar")
                        }
                        .tag(AppState.Tab.bookings)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(AppState.Tab.profile)
                }
            } else {
                SignInView()
            }
        }
        .sheet(isPresented: $appState.showingBookingSheet) {
            BookingView()
        }
        .sheet(isPresented: $appState.showingPaymentSheet) {
            PaymentView()
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject
    private var authService: AuthenticationService
    
    @State
    private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if let userData = authService.userData {
                    Section("Personal Information") {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(userData.name)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(userData.email)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Phone")
                            Spacer()
                            Text(userData.phone)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Text("Sign Out")
                            Spacer()
                            Image(systemName: "arrow.right.square")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    try? authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState.shared)
            .environmentObject(AuthenticationService.shared)
    }
}
