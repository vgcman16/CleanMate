import XCTest
@testable import CleanMate
import FirebaseAuth
import FirebaseFirestore

final class AuthenticationServiceTests: XCTestCase {
    var sut: AuthenticationService!
    var mockAuth: MockAuth!
    var mockFirestore: MockFirestore!
    
    override func setUp() {
        super.setUp()
        mockAuth = MockAuth()
        mockFirestore = MockFirestore()
        sut = AuthenticationService.shared
    }
    
    override func tearDown() {
        sut = nil
        mockAuth = nil
        mockFirestore = nil
        super.tearDown()
    }
    
    func testSignInSuccess() async throws {
        // Given
        let email = "test@example.com"
        let password = "password123"
        mockAuth.shouldSucceed = true
        
        // When
        try await sut.signIn(email: email, password: password)
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
    }
    
    func testSignInFailure() async {
        // Given
        let email = "test@example.com"
        let password = "password123"
        mockAuth.shouldSucceed = false
        mockAuth.error = NSError(domain: "auth", code: -1, userInfo: nil)
        
        // When/Then
        do {
            try await sut.signIn(email: email, password: password)
            XCTFail("Should throw error")
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
        mockAuth.shouldSucceed = true
        mockFirestore.shouldSucceed = true
        
        // When
        try await sut.signUp(email: email, password: password, name: name, phone: phone)
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
        XCTAssertNotNil(sut.userData)
        XCTAssertEqual(sut.userData?.name, name)
    }
    
    func testSignOut() throws {
        // Given
        mockAuth.shouldSucceed = true
        
        // When
        try sut.signOut()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertNil(sut.userData)
    }
}

// MARK: - Mocks

class MockAuth: Auth {
    var shouldSucceed = true
    var error: Error?
    
    override func signIn(withEmail email: String, password: String) async throws -> AuthDataResult {
        if shouldSucceed {
            return MockAuthDataResult()
        }
        throw error ?? NSError(domain: "auth", code: -1, userInfo: nil)
    }
}

class MockFirestore {
    var shouldSucceed = true
    var error: Error?
    
    func collection(_ path: String) -> MockCollectionReference {
        MockCollectionReference(shouldSucceed: shouldSucceed, error: error)
    }
}

class MockCollectionReference {
    let shouldSucceed: Bool
    let error: Error?
    
    init(shouldSucceed: Bool, error: Error?) {
        self.shouldSucceed = shouldSucceed
        self.error = error
    }
    
    func document(_ path: String) -> MockDocumentReference {
        MockDocumentReference(shouldSucceed: shouldSucceed, error: error)
    }
}

class MockDocumentReference {
    let shouldSucceed: Bool
    let error: Error?
    
    init(shouldSucceed: Bool, error: Error?) {
        self.shouldSucceed = shouldSucceed
        self.error = error
    }
    
    func setData(_ data: [String: Any]) async throws {
        if !shouldSucceed {
            throw error ?? NSError(domain: "firestore", code: -1, userInfo: nil)
        }
    }
}

class MockAuthDataResult: AuthDataResult {
    override var user: User {
        MockUser()
    }
}

class MockUser: User {
    override var uid: String {
        "mock-uid"
    }
    
    override var email: String? {
        "test@example.com"
    }
}
