import XCTest
@testable import CleanMate
import FirebaseAuth
import FirebaseFirestore

final class BookingServiceTests: XCTestCase {
    var sut: BookingService!
    var mockFirestore: MockFirestore!
    var mockAuth: MockAuth!
    
    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestore()
        mockAuth = MockAuth()
        sut = BookingService.shared
    }
    
    override func tearDown() {
        sut = nil
        mockFirestore = nil
        mockAuth = nil
        super.tearDown()
    }
    
    func testCreateBookingSuccess() async throws {
        // Given
        let booking = Booking.mock()
        mockAuth.shouldSucceed = true
        let bookingsCollection = mockFirestore.collection("bookings")
        
        // When
        let bookingId = try await sut.createBooking(booking)
        
        // Then
        XCTAssertNotNil(bookingId)
        XCTAssertNotNil(bookingsCollection.documents[bookingId])
    }
    
    func testCreateBookingFailureUnauthenticated() async {
        // Given
        let booking = Booking.mock()
        mockAuth.shouldSucceed = false
        
        // When/Then
        do {
            _ = try await sut.createBooking(booking)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(
                (error as NSError).domain,
                "BookingService"
            )
            XCTAssertEqual(
                (error as NSError).code,
                401
            )
        }
    }
    
    func testGetBookingsSuccess() async throws {
        // Given
        mockAuth.shouldSucceed = true
        let mockBookings = [
            Booking.mock(id: "1"),
            Booking.mock(id: "2"),
            Booking.mock(id: "3")
        ]
        
        let mockSnapshots = mockBookings.map { booking in
            MockDocumentSnapshot(data: try! JSONSerialization.jsonObject(
                with: JSONEncoder().encode(booking),
                options: .allowFragments
            ) as! [String: Any])
        }
        
        let bookingsCollection = mockFirestore.collection("bookings")
        bookingsCollection.queryResults = mockSnapshots
        
        // When
        let bookings = try await sut.getBookings()
        
        // Then
        XCTAssertEqual(bookings.count, mockBookings.count)
        XCTAssertEqual(bookings[0].id, mockBookings[0].id)
    }
    
    func testUpdateBookingStatusSuccess() async throws {
        // Given
        let bookingId = "test-booking"
        let newStatus = Booking.BookingStatus.completed
        let bookingsCollection = mockFirestore.collection("bookings")
        let bookingDoc = bookingsCollection.document(bookingId)
        
        // When
        try await sut.updateBookingStatus(bookingId, status: newStatus)
        
        // Then
        let updatedData = bookingDoc.data
        XCTAssertEqual(updatedData?["status"] as? String, newStatus.rawValue)
    }
    
    func testCancelBookingSuccess() async throws {
        // Given
        let bookingId = "test-booking"
        let bookingsCollection = mockFirestore.collection("bookings")
        let bookingDoc = bookingsCollection.document(bookingId)
        
        // When
        try await sut.cancelBooking(bookingId)
        
        // Then
        let updatedData = bookingDoc.data
        XCTAssertEqual(
            updatedData?["status"] as? String,
            Booking.BookingStatus.cancelled.rawValue
        )
    }
    
    func testGetBookingsFailureUnauthenticated() async {
        // Given
        mockAuth.shouldSucceed = false
        
        // When/Then
        do {
            _ = try await sut.getBookings()
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(
                (error as NSError).domain,
                "BookingService"
            )
            XCTAssertEqual(
                (error as NSError).code,
                401
            )
        }
    }
}

// MARK: - Test Helpers

extension BookingServiceTests {
    func createMockBookingDocument(
        _ booking: Booking,
        in collection: MockCollectionReference
    ) throws {
        let data = try JSONSerialization.jsonObject(
            with: JSONEncoder().encode(booking),
            options: .allowFragments
        ) as! [String: Any]
        
        let document = collection.document(booking.id ?? "")
        try document.setData(data)
    }
}
