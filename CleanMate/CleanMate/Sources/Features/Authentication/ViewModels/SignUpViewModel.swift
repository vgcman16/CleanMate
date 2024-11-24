import Foundation

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    @Published var phone = ""
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let authService: AuthenticationService
    
    init(authService: AuthenticationService = .shared) {
        self.authService = authService
    }
    
    func signUp() async {
        guard validateInputs() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.signUp(
                email: email,
                password: password,
                name: name,
                phone: phone
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func validateInputs() -> Bool {
        if name.isEmpty {
            errorMessage = "Please enter your name"
            showError = true
            return false
        }
        
        if email.isEmpty {
            errorMessage = "Please enter your email"
            showError = true
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        if phone.isEmpty {
            errorMessage = "Please enter your phone number"
            showError = true
            return false
        }
        
        if !isValidPhone(phone) {
            errorMessage = "Please enter a valid phone number"
            showError = true
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Please enter a password"
            showError = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
}
