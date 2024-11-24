import XCTest
@testable import CleanMate

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
        mockAuthService.shouldSucceed = true
        sut.email = "test@example.com"
        sut.password = "password123"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertFalse(sut.showError)
        XCTAssertTrue(mockAuthService.isAuthenticated)
    }
    
    func testSignInFailureInvalidEmail() async {
        // Given
        sut.email = "invalid-email"
        sut.password = "password123"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please enter a valid email address")
    }
    
    func testSignInFailureEmptyPassword() async {
        // Given
        sut.email = "test@example.com"
        sut.password = ""
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please enter your password")
    }
}

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
        mockAuthService.shouldSucceed = true
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.name = "Test User"
        sut.phone = "1234567890"
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertFalse(sut.showError)
        XCTAssertTrue(mockAuthService.isAuthenticated)
    }
    
    func testSignUpFailureEmptyName() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.name = ""
        sut.phone = "1234567890"
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please enter your name")
    }
    
    func testSignUpFailureInvalidEmail() async {
        // Given
        sut.email = "invalid-email"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.name = "Test User"
        sut.phone = "1234567890"
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please enter a valid email address")
    }
    
    func testSignUpFailureInvalidPhone() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
        sut.name = "Test User"
        sut.phone = "invalid-phone"
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Please enter a valid phone number")
    }
    
    func testSignUpFailurePasswordMismatch() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.confirmPassword = "different"
        sut.name = "Test User"
        sut.phone = "1234567890"
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Passwords do not match")
    }
    
    func testSignUpFailureWeakPassword() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "123"
        sut.confirmPassword = "123"
        sut.name = "Test User"
        sut.phone = "1234567890"
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Password must be at least 6 characters")
    }
}

// MARK: - Mock Service

class MockAuthenticationService: AuthenticationService {
    var shouldSucceed = true
    var error: Error?
    
    override func signIn(email: String, password: String) async throws {
        if shouldSucceed {
            isAuthenticated = true
            currentUser = MockUser()
        } else {
            throw error ?? NSError(domain: "auth", code: -1, userInfo: nil)
        }
    }
    
    override func signUp(email: String, password: String, name: String, phone: String) async throws {
        if shouldSucceed {
            isAuthenticated = true
            currentUser = MockUser()
            userData = UserData(id: "mock-id", email: email, name: name, phone: phone)
        } else {
            throw error ?? NSError(domain: "auth", code: -1, userInfo: nil)
        }
    }
}
