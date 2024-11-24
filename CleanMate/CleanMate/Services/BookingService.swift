import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class BookingService: ObservableObject {
    static let shared = BookingService()
    private let db = Firestore.firestore()
    
    @Published var services: [CleaningService] = []
    @Published var popularServices: [CleaningService] = []
    @Published var upcomingBookings: [Booking] = []
    
    private init() {
        fetchServices()
        if let userId = AuthenticationService.shared.currentUser?.id {
            fetchUpcomingBookings(for: userId)
        }
    }
    
    func fetchServices() {
        db.collection("services")
            .whereField("isAvailable", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching services: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.services = documents.compactMap { try? $0.data(as: CleaningService.self) }
                self?.popularServices = self?.services.filter { $0.isPopular } ?? []
            }
    }
    
    func fetchUpcomingBookings(for userId: String) {
        let currentDate = Date()
        
        db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .whereField("scheduledDate", isGreaterThan: currentDate)
            .whereField("status", isNotEqualTo: BookingStatus.cancelled.rawValue)
            .order(by: "scheduledDate")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching bookings: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.upcomingBookings = documents.compactMap { try? $0.data(as: Booking.self) }
            }
    }
    
    func createBooking(_ booking: Booking) async throws -> String {
        let bookingRef = db.collection("bookings").document()
        var bookingWithId = booking
        bookingWithId.id = bookingRef.documentID
        
        try bookingRef.setData(from: bookingWithId)
        return bookingRef.documentID
    }
    
    func cancelBooking(_ bookingId: String) async throws {
        try await db.collection("bookings").document(bookingId).updateData([
            "status": BookingStatus.cancelled.rawValue,
            "updatedAt": Date()
        ])
    }
    
    func getAvailableTimeSlots(for date: Date, serviceId: String) async throws -> [TimeSlot] {
        // In a real app, this would check against existing bookings and service provider availability
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        var timeSlots: [TimeSlot] = []
        let workingHours = 8...20 // 8 AM to 8 PM
        
        for hour in workingHours {
            guard let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startOfDay),
                  let endTime = calendar.date(byAdding: .hour, value: 2, to: startTime) else {
                continue
            }
            
            timeSlots.append(TimeSlot(
                startTime: startTime,
                endTime: endTime,
                isAvailable: true
            ))
        }
        
        return timeSlots
    }
    
    func calculatePrice(service: CleaningService, numberOfRooms: Int) -> Decimal {
        switch service.priceUnit {
        case .perRoom:
            return service.basePrice * Decimal(max(numberOfRooms, service.minimumRooms))
        case .perHour:
            let estimatedHours = Decimal(service.estimatedDuration) / 60
            return service.basePrice * estimatedHours
        case .fixed:
            return service.basePrice
        }
    }
}
