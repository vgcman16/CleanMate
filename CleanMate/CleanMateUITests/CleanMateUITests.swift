import XCTest

final class CleanMateUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testSignInFlow() throws {
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.exists)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)
        
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists)
    }
    
    func testSignUpFlow() throws {
        let signUpLink = app.buttons["Don't have an account? Sign Up"]
        XCTAssertTrue(signUpLink.exists)
        signUpLink.tap()
        
        let nameTextField = app.textFields["Full Name"]
        XCTAssertTrue(nameTextField.exists)
        
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.exists)
        
        let phoneTextField = app.textFields["Phone"]
        XCTAssertTrue(phoneTextField.exists)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)
        
        let confirmPasswordSecureTextField = app.secureTextFields["Confirm Password"]
        XCTAssertTrue(confirmPasswordSecureTextField.exists)
        
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.exists)
    }
}
