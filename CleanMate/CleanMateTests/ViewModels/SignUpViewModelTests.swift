import XCTest
@testable import CleanMate

@MainActor
final class SignUpViewModelTests: XCTestCase {
    var sut: SignUpViewModel!
    var mockAuthService: MockAuthenticationService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        sut = SignUpViewModel(authService: mockAuthService)
    }
    
    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testSignUpSuccess() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.name = "Test User"
        sut.phone = "1234567890"
        mockAuthService.shouldThrowError = false
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(mockAuthService.signUpCalled)
        XCTAssertFalse(sut.showError)
        XCTAssertTrue(sut.errorMessage.isEmpty)
    }
    
    func testSignUpFailure() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.name = "Test User"
        sut.phone = "1234567890"
        mockAuthService.shouldThrowError = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(mockAuthService.signUpCalled)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testSignUpValidation() async {
        // Given
        sut.email = ""
        sut.password = ""
        sut.confirmPassword = ""
        sut.name = ""
        sut.phone = ""
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertFalse(mockAuthService.signUpCalled)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testSignUpPasswordMismatch() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password456"
        sut.name = "Test User"
        sut.phone = "1234567890"
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertFalse(mockAuthService.signUpCalled)
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Passwords do not match")
    }
}
