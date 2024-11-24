import Foundation

@MainActor
class BookingViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var showError = false
    @Published private(set) var errorMessage = ""
    @Published var selectedDate = Date()
    @Published var selectedTime = Date()
    @Published var selectedAddress: Address?
    @Published var numberOfRooms = 1
    @Published var specialInstructions = ""
    @Published var showAddressSheet = false
    @Published var showPaymentSheet = false
    
    private let service: CleaningService
    private let bookingService: BookingService
    
    init(
        service: CleaningService,
        bookingService: BookingService = .shared
    ) {
        self.service = service
        self.bookingService = bookingService
    }
    
    var totalAmount: Double {
        service.basePrice * Double(numberOfRooms)
    }
    
    func createBooking() async -> Bool {
        guard validateBooking() else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let booking = createBookingObject()
            _ = try await bookingService.createBooking(booking)
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            return false
        }
    }
    
    private func validateBooking() -> Bool {
        guard selectedAddress != nil else {
            errorMessage = "Please select an address"
            showError = true
            return false
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(selectedDate) {
            let currentHour = calendar.component(.hour, from: now)
            let selectedHour = calendar.component(.hour, from: selectedTime)
            
            if selectedHour <= currentHour {
                errorMessage = "Please select a future time"
                showError = true
                return false
            }
        }
        
        return true
    }
    
    private func createBookingObject() -> Booking {
        let timeSlot = TimeSlot(
            start: selectedTime,
            end: Calendar.current.date(
                byAdding: .hour,
                value: 2,
                to: selectedTime
            ) ?? selectedTime
        )
        
        return Booking(
            userId: "", // Will be set by BookingService
            serviceId: service.id ?? "",
            scheduledDate: selectedDate,
            scheduledTime: timeSlot,
            status: .upcoming,
            address: selectedAddress!,
            createdAt: Date()
        )
    }
    
    func incrementRooms() {
        if numberOfRooms < 10 {
            numberOfRooms += 1
        }
    }
    
    func decrementRooms() {
        if numberOfRooms > 1 {
            numberOfRooms -= 1
        }
    }
}
