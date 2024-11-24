import XCTest
@testable import CleanMate

@MainActor
final class BookingViewModelTests: XCTestCase {
    var sut: BookingViewModel!
    var mockBookingService: MockBookingService!
    
    override func setUp() {
        super.setUp()
        let service = CleaningService(
            id: "test-id",
            name: "Test Service",
            description: "Test Description",
            basePrice: 100,
            imageURL: nil,
            category: .regular,
            isPopular: true,
            createdAt: Date()
        )
        mockBookingService = MockBookingService()
        sut = BookingViewModel(
            service: service,
            bookingService: mockBookingService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockBookingService = nil
        super.tearDown()
    }
    
    func testCreateBookingSuccess() async {
        // Given
        sut.selectedAddress = Address(
            street: "123 Test St",
            city: "Test City",
            state: "Test State",
            zipCode: "12345",
            country: "Test Country"
        )
        mockBookingService.shouldThrowError = false
        
        // When
        let result = await sut.createBooking()
        
        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockBookingService.createBookingCalled)
        XCTAssertFalse(sut.showError)
        XCTAssertTrue(sut.errorMessage.isEmpty)
    }
    
    func testCreateBookingFailure() async {
        // Given
        sut.selectedAddress = Address(
            street: "123 Test St",
            city: "Test City",
            state: "Test State",
            zipCode: "12345",
            country: "Test Country"
        )
        mockBookingService.shouldThrowError = true
        
        // When
        let result = await sut.createBooking()
        
        // Then
        XCTAssertFalse(result)
        XCTAssertTrue(mockBookingService.createBookingCalled)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testCreateBookingValidation() async {
        // Given
        sut.selectedAddress = nil
        
        // When
        let result = await sut.createBooking()
        
        // Then
        XCTAssertFalse(result)
        XCTAssertFalse(mockBookingService.createBookingCalled)
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please select an address")
    }
    
    func testTotalAmount() {
        // Given
        sut.numberOfRooms = 3
        
        // Then
        XCTAssertEqual(sut.totalAmount, 300)
    }
    
    func testIncrementRooms() {
        // Given
        sut.numberOfRooms = 5
        
        // When
        sut.incrementRooms()
        
        // Then
        XCTAssertEqual(sut.numberOfRooms, 6)
    }
    
    func testDecrementRooms() {
        // Given
        sut.numberOfRooms = 5
        
        // When
        sut.decrementRooms()
        
        // Then
        XCTAssertEqual(sut.numberOfRooms, 4)
    }
}
