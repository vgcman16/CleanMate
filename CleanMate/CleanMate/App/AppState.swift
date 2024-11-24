import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedTab: Tab = .home
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        AuthenticationService.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
            .store(in: &cancellables)
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

enum Tab: String {
    case home = "house.fill"
    case bookings = "calendar"
    case messages = "message.fill"
    case profile = "person.fill"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .bookings: return "Bookings"
        case .messages: return "Messages"
        case .profile: return "Profile"
        }
    }
}
