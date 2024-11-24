import XCTest
import FirebaseAuth
@testable import CleanMate

@MainActor
class MockAuthenticationService: AuthenticationService {
    var signInCalled = false
    var signUpCalled = false
    var signOutCalled = false
    var resetPasswordCalled = false
    var shouldThrowError = false
    
    override func signIn(email: String, password: String) async throws {
        if shouldThrowError {
            throw NSError(domain: "test", code: 401)
        }
        signInCalled = true
    }
    
    override func signUp(
        email: String,
        password: String,
        name: String,
        phone: String
    ) async throws {
        if shouldThrowError {
            throw NSError(domain: "test", code: 401)
        }
        signUpCalled = true
    }
    
    override func signOut() throws {
        if shouldThrowError {
            throw NSError(domain: "test", code: 401)
        }
        signOutCalled = true
    }
    
    override func resetPassword(email: String) async throws {
        if shouldThrowError {
            throw NSError(domain: "test", code: 401)
        }
        resetPasswordCalled = true
    }
}

@MainActor
class MockBookingService: BookingService {
    var createBookingCalled = false
    var getBookingsCalled = false
    var cancelBookingCalled = false
    var shouldThrowError = false
    var mockBookings: [Booking] = []
    
    override func createBooking(_ booking: Booking) async throws -> String {
        if shouldThrowError {
            throw NSError(domain: "test", code: 401)
        }
        createBookingCalled = true
        return "test-booking-id"
    }
    
    override func getBookings() async throws -> [Booking] {
        if shouldThrowError {
            throw NSError(domain: "test", code: 401)
        }
        getBookingsCalled = true
        return mockBookings
    }
    
    override func cancelBooking(_ bookingId: String) async throws {
        if shouldThrowError {
            throw NSError(domain: "test", code: 401)
        }
        cancelBookingCalled = true
    }
}
