import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

class BookingService: ObservableObject {
    static let shared = BookingService()
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
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
        guard let userId = auth.currentUser?.uid else {
            throw BookingError.invalidUser
        }
        
        do {
            let docRef = try await db
                .collection("bookings")
                .addDocument(data: [
                    "userId": userId,
                    "serviceId": booking.service.id,
                    "addressId": booking.address.id,
                    "date": booking.date,
                    "status": booking.status.rawValue,
                    "totalAmount": booking.totalAmount,
                    "numberOfRooms": booking.numberOfRooms,
                    "specialInstructions": booking.specialInstructions ?? "",
                    "createdAt": Timestamp()
                ])
            
            return docRef.documentID
        } catch {
            throw BookingError.bookingCreationFailed(error.localizedDescription)
        }
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
    
    enum BookingError: LocalizedError {
        case invalidBooking
        case invalidUser
        case invalidService
        case invalidAddress
        case invalidDate
        case invalidPayment
        case bookingCreationFailed(String)
        case bookingUpdateFailed(String)
        case bookingDeletionFailed(String)
        case bookingNotFound
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidBooking:
                return "Invalid booking details."
            case .invalidUser:
                return "User information is missing."
            case .invalidService:
                return "Service information is missing."
            case .invalidAddress:
                return "Address information is missing."
            case .invalidDate:
                return "Invalid booking date."
            case .invalidPayment:
                return "Payment information is missing."
            case .bookingCreationFailed(let message):
                return "Failed to create booking: \(message)"
            case .bookingUpdateFailed(let message):
                return "Failed to update booking: \(message)"
            case .bookingDeletionFailed(let message):
                return "Failed to delete booking: \(message)"
            case .bookingNotFound:
                return "Booking not found."
            case .unknown(let error):
                return error.localizedDescription
            }
        }
    }
}
