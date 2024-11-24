import XCTest
@testable import CleanMate

final class BookingViewModelTests: XCTestCase {
    var sut: BookingViewModel!
    var mockBookingService: MockBookingService!
    var mockService: CleaningService!
    
    override func setUp() {
        super.setUp()
        mockBookingService = MockBookingService()
        mockService = CleaningService.mock()
        sut = BookingViewModel(
            service: mockService,
            bookingService: mockBookingService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockBookingService = nil
        mockService = nil
        super.tearDown()
    }
    
    func testCreateBookingSuccess() async {
        // Given
        mockBookingService.shouldSucceed = true
        sut.selectedAddress = Address.mock()
        sut.selectedDate = Date()
        sut.selectedTime = Date()
        
        // When
        let success = await sut.createBooking()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertFalse(sut.showError)
        XCTAssertTrue(sut.showPaymentSheet)
    }
    
    func testCreateBookingFailureNoAddress() async {
        // Given
        sut.selectedAddress = nil
        
        // When
        let success = await sut.createBooking()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please select an address")
    }
    
    func testCreateBookingFailurePastTime() async {
        // Given
        sut.selectedAddress = Address.mock()
        sut.selectedDate = Date()
        sut.selectedTime = Calendar.current.date(
            byAdding: .hour,
            value: -1,
            to: Date()
        )!
        
        // When
        let success = await sut.createBooking()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please select a future time")
    }
    
    func testTotalAmountCalculation() {
        // Given
        let basePrice = mockService.basePrice
        let numberOfRooms = 3
        
        // When
        sut.numberOfRooms = numberOfRooms
        
        // Then
        XCTAssertEqual(sut.totalAmount, basePrice * Double(numberOfRooms))
    }
    
    func testIncrementRooms() {
        // Given
        sut.numberOfRooms = 5
        
        // When
        sut.incrementRooms()
        
        // Then
        XCTAssertEqual(sut.numberOfRooms, 6)
    }
    
    func testIncrementRoomsLimit() {
        // Given
        sut.numberOfRooms = 10
        
        // When
        sut.incrementRooms()
        
        // Then
        XCTAssertEqual(sut.numberOfRooms, 10)
    }
    
    func testDecrementRooms() {
        // Given
        sut.numberOfRooms = 5
        
        // When
        sut.decrementRooms()
        
        // Then
        XCTAssertEqual(sut.numberOfRooms, 4)
    }
    
    func testDecrementRoomsLimit() {
        // Given
        sut.numberOfRooms = 1
        
        // When
        sut.decrementRooms()
        
        // Then
        XCTAssertEqual(sut.numberOfRooms, 1)
    }
}

// MARK: - Mock Service

class MockBookingService: BookingService {
    var shouldSucceed = true
    var error: Error?
    
    override func createBooking(_ booking: Booking) async throws -> String {
        if shouldSucceed {
            return "mock-booking-id"
        }
        throw error ?? NSError(domain: "booking", code: -1, userInfo: nil)
    }
}
