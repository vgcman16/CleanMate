import XCTest
@testable import CleanMate

@MainActor
final class SignInViewModelTests: XCTestCase {
    var sut: SignInViewModel!
    var mockAuthService: MockAuthenticationService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        sut = SignInViewModel(authService: mockAuthService)
    }
    
    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testSignInSuccess() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        mockAuthService.shouldThrowError = false
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(mockAuthService.signInCalled)
        XCTAssertFalse(sut.showError)
        XCTAssertTrue(sut.errorMessage.isEmpty)
    }
    
    func testSignInFailure() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        mockAuthService.shouldThrowError = true
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(mockAuthService.signInCalled)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testSignInValidation() async {
        // Given
        sut.email = ""
        sut.password = ""
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertFalse(mockAuthService.signInCalled)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
}
