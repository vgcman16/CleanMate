import Combine
import FirebaseAuth
import PhoneNumberKit
import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Full Name", text: $viewModel.fullName)
                        .textContentType(.name)
                    
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone", text: $viewModel.phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                } header: {
                    Text("Account Details")
                }
                
                Section {
                    Toggle("Accept Terms", isOn: $viewModel.acceptedTerms)
                    
                    Button(action: { viewModel.showTerms = true }) {
                        Text("View Terms and Conditions")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Terms and Conditions")
                }
                
                Button(action: { Task { await viewModel.signUp() } }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.isValid || viewModel.isLoading)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "Error",
                isPresented: $viewModel.showError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .sheet(
                isPresented: $viewModel.showTerms
            ) {
                TermsView(
                    isPresented: $viewModel.showTerms,
                    onAccept: { viewModel.acceptedTerms = true }
                )
            }
        }
    }
}

class SignUpViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var acceptedTerms = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showTerms = false
    
    private let phoneNumberKit = PhoneNumberKit()
    
    var isValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        isValidPhoneNumber &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        acceptedTerms
    }
    
    var isValidPhoneNumber: Bool {
        do {
            _ = try phoneNumberKit.parse(phoneNumber)
            return true
        } catch {
            return false
        }
    }
    
    func signUp() async {
        guard isValid else { return }
        
        isLoading = true
        do {
            try await AuthenticationService.shared.signUp(
                email: email,
                password: password,
                fullName: fullName,
                phoneNumber: phoneNumber
            )
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}

struct TermsView: View {
    @Binding var isPresented: Bool
    let onAccept: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms and Conditions")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("""
                        1. Service Agreement
                        By using CleanMate, you agree to abide by our service terms.
                        
                        2. Booking and Cancellation
                        - 24-hour notice required for cancellation
                        - Late cancellations may incur fees
                        
                        3. Payment Terms
                        - Payment is processed after service completion
                        - All major credit cards accepted
                        
                        4. Privacy Policy
                        We protect your personal information as outlined in our privacy policy.
                        """)
                }
                .padding()
            }
            .navigationBarItems(
                leading: Button("Close") {
                    isPresented = false
                },
                trailing: Button("Accept") {
                    onAccept()
                    isPresented = false
                }
            )
        }
    }
}
