import Foundation

@MainActor
class SignInViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var showError = false
    @Published private(set) var errorMessage = ""
    
    @Published var email = ""
    @Published var password = ""
    
    private let authService: AuthenticationService
    
    init(authService: AuthenticationService = .shared) {
        self.authService = authService
    }
    
    func signIn() async {
        guard validateInputs() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.signIn(
                email: email,
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func validateInputs() -> Bool {
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
        
        if password.isEmpty {
            errorMessage = "Please enter your password"
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
}
