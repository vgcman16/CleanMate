import XCTest
@testable import CleanMate

@MainActor final class BookingServiceTests: XCTestCase {
    var sut: BookingService!
    
    override func setUp() {
        super.setUp()
        sut = BookingService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCreateBookingSuccess() async throws {
        // Given
        let booking = Booking(
            userId: "test-user-id",
            serviceId: "test-service-id",
            scheduledDate: Date(),
            scheduledTime: TimeSlot(
                start: Date(),
                end: Date().addingTimeInterval(7_200)
            ),
            status: .upcoming,
            address: Address(
                street: "123 Test St",
                city: "Test City",
                state: "Test State",
                zipCode: "12345",
                country: "Test Country"
            ),
            createdAt: Date()
        )
        
        // When
        let bookingId = try await sut.createBooking(booking)
        
        // Then
        XCTAssertFalse(bookingId.isEmpty)
    }
    
    func testGetBookingsSuccess() async throws {
        // When
        let bookings = try await sut.getBookings()
        
        // Then
        XCTAssertNotNil(bookings)
    }
    
    func testCancelBookingSuccess() async throws {
        // Given
        let bookingId = "test-booking-id"
        
        // When/Then
        XCTAssertNoThrow(try await sut.cancelBooking(bookingId))
    }
    
    func testUpdateBookingStatusSuccess() async throws {
        // Given
        let bookingId = "test-booking-id"
        let status = Booking.BookingStatus.cancelled
        
        // When/Then
        XCTAssertNoThrow(try await sut.updateBookingStatus(bookingId, status: status))
    }
}
