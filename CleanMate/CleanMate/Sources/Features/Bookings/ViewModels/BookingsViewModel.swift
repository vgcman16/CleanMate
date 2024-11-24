import Foundation

@MainActor
class BookingsViewModel: ObservableObject {
    @Published
    private(set) var bookings: [Booking] = []
    
    @Published
    private(set) var isLoading = false
    
    @Published
    private(set) var showError = false
    
    @Published
    private(set) var errorMessage = ""
    
    private let bookingService: BookingService
    
    init(bookingService: BookingService = .shared) {
        self.bookingService = bookingService
    }
    
    func fetchBookings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            bookings = try await bookingService.getBookings()
            bookings.sort { $0.scheduledDate > $1.scheduledDate }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func cancelBooking(_ bookingId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await bookingService.cancelBooking(bookingId)
            await fetchBookings()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    var upcomingBookings: [Booking] {
        bookings.filter { $0.status == .upcoming }
    }
    
    var completedBookings: [Booking] {
        bookings.filter { $0.status == .completed }
    }
    
    var cancelledBookings: [Booking] {
        bookings.filter { $0.status == .cancelled }
    }
}
