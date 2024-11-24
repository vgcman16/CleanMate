import XCTest

final class CleanMateUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testSignInFlow() {
        // Given
        let emailTextField = app.textFields["Email"]
        let passwordSecureField = app.secureTextFields["Password"]
        let signInButton = app.buttons["Sign In"]
        
        // When
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        passwordSecureField.tap()
        passwordSecureField.typeText("password123")
        
        signInButton.tap()
        
        // Then
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }
    
    func testSignUpFlow() {
        // Given
        app.buttons["Don't have an account? Sign Up"].tap()
        
        let nameTextField = app.textFields["Full Name"]
        let emailTextField = app.textFields["Email"]
        let phoneTextField = app.textFields["Phone"]
        let passwordSecureField = app.secureTextFields["Password"]
        let confirmPasswordSecureField = app.secureTextFields["Confirm Password"]
        let signUpButton = app.buttons["Sign Up"]
        
        // When
        nameTextField.tap()
        nameTextField.typeText("Test User")
        
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        phoneTextField.tap()
        phoneTextField.typeText("1234567890")
        
        passwordSecureField.tap()
        passwordSecureField.typeText("password123")
        
        confirmPasswordSecureField.tap()
        confirmPasswordSecureField.typeText("password123")
        
        signUpButton.tap()
        
        // Then
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }
    
    func testBookingFlow() {
        // Given
        testSignInFlow() // Sign in first
        
        let bookButton = app.buttons["Book Now"]
        let addAddressButton = app.buttons["Add Address"]
        let streetTextField = app.textFields["Street"]
        let cityTextField = app.textFields["City"]
        let stateTextField = app.textFields["State"]
        let zipCodeTextField = app.textFields["ZIP Code"]
        let countryTextField = app.textFields["Country"]
        let saveAddressButton = app.buttons["Save Address"]
        let continueToPaymentButton = app.buttons["Continue to Payment"]
        
        // When
        bookButton.tap()
        addAddressButton.tap()
        
        streetTextField.tap()
        streetTextField.typeText("123 Test St")
        
        cityTextField.tap()
        cityTextField.typeText("Test City")
        
        stateTextField.tap()
        stateTextField.typeText("Test State")
        
        zipCodeTextField.tap()
        zipCodeTextField.typeText("12345")
        
        countryTextField.tap()
        countryTextField.typeText("Test Country")
        
        saveAddressButton.tap()
        continueToPaymentButton.tap()
        
        // Then
        XCTAssertTrue(app.navigationBars["Payment"].exists)
    }
}
