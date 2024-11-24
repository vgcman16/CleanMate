import SwiftUI

class AppState: ObservableObject {
    @Published
    var isAuthenticated = false
    
    @Published
    var currentTab: Tab = .home
    
    @Published
    var showingBookingSheet = false
    
    @Published
    var showingPaymentSheet = false
    
    static let shared = AppState()
    
    private init() {}
    
    enum Tab {
        case home
        case bookings
        case profile
    }
}
