import XCTest
@testable import CleanMate

@MainActor final class AuthenticationServiceTests: XCTestCase {
    var sut: AuthenticationService!
    
    override func setUp() {
        super.setUp()
        sut = AuthenticationService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSignInSuccess() async throws {
        // Given
        let email = "test@example.com"
        let password = "password123"
        
        // When
        try await sut.signIn(email: email, password: password)
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
    }
    
    func testSignInFailure() async {
        // Given
        let email = "invalid@example.com"
        let password = "wrongpassword"
        
        // When/Then
        do {
            try await sut.signIn(email: email, password: password)
            XCTFail("Expected sign in to fail")
        } catch {
            XCTAssertFalse(sut.isAuthenticated)
            XCTAssertNil(sut.currentUser)
        }
    }
    
    func testSignUpSuccess() async throws {
        // Given
        let email = "test@example.com"
        let password = "password123"
        let name = "Test User"
        let phone = "1234567890"
        
        // When
        try await sut.signUp(
            email: email,
            password: password,
            name: name,
            phone: phone
        )
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
        XCTAssertNotNil(sut.userData)
        XCTAssertEqual(sut.userData?.email, email)
        XCTAssertEqual(sut.userData?.name, name)
        XCTAssertEqual(sut.userData?.phone, phone)
    }
    
    func testSignUpFailure() async {
        // Given
        let email = "invalid@example.com"
        let password = "short"
        let name = "Test User"
        let phone = "1234567890"
        
        // When/Then
        do {
            try await sut.signUp(
                email: email,
                password: password,
                name: name,
                phone: phone
            )
            XCTFail("Expected sign up to fail")
        } catch {
            XCTAssertFalse(sut.isAuthenticated)
            XCTAssertNil(sut.currentUser)
            XCTAssertNil(sut.userData)
        }
    }
    
    func testSignOut() throws {
        // Given
        sut.isAuthenticated = true
        
        // When
        try sut.signOut()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertNil(sut.userData)
    }
}
