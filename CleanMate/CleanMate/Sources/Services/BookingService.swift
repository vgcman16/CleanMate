import FirebaseFirestore
import FirebaseAuth
import Foundation

@MainActor
class BookingService {
    static let shared = BookingService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private init() {}
    
    func createBooking(_ booking: Booking) async throws -> String {
        guard let userId = auth.currentUser?.uid else {
            throw NSError(
                domain: "BookingService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }
        
        let bookingData = try JSONEncoder().encode(booking)
        let bookingDict = try JSONSerialization.jsonObject(
            with: bookingData,
            options: .allowFragments
        ) as? [String: Any] ?? [:]
        
        let document = try await db.collection("bookings")
            .addDocument(data: bookingDict)
        
        return document.documentID
    }
    
    func getBookings() async throws -> [Booking] {
        guard let userId = auth.currentUser?.uid else {
            throw NSError(
                domain: "BookingService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }
        
        let snapshot = try await db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Booking.self)
        }
    }
    
    func updateBookingStatus(
        _ bookingId: String,
        status: Booking.BookingStatus
    ) async throws {
        try await db.collection("bookings")
            .document(bookingId)
            .updateData([
                "status": status.rawValue,
                "updatedAt": FieldValue.serverTimestamp()
            ])
    }
    
    func cancelBooking(_ bookingId: String) async throws {
        try await updateBookingStatus(bookingId, status: .cancelled)
    }
}
