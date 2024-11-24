import SwiftUI
import PhoneNumberKit

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    CustomTextField(text: $viewModel.fullName,
                                 placeholder: "Full Name",
                                 icon: "person.fill")
                        .textContentType(.name)
                    
                    CustomTextField(text: $viewModel.email,
                                 placeholder: "Email",
                                 icon: "envelope.fill")
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    PhoneNumberField(text: $viewModel.phoneNumber,
                                   placeholder: "Phone Number")
                    
                    CustomSecureField(text: $viewModel.password,
                                    placeholder: "Password",
                                    icon: "lock.fill")
                        .textContentType(.newPassword)
                    
                    CustomSecureField(text: $viewModel.confirmPassword,
                                    placeholder: "Confirm Password",
                                    icon: "lock.fill")
                        .textContentType(.newPassword)
                }
                .padding(.horizontal)
                
                // Terms and Conditions
                HStack {
                    Toggle("", isOn: $viewModel.acceptedTerms)
                        .labelsHidden()
                    
                    Text("I accept the ")
                    Button("Terms and Conditions") {
                        viewModel.showTerms = true
                    }
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                // Sign Up Button
                Button(action: {
                    Task {
                        await viewModel.signUp()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(!viewModel.isValid || viewModel.isLoading)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showTerms) {
            TermsAndConditionsView()
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

struct PhoneNumberField: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "phone.fill")
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct TermsAndConditionsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("""
                    Terms and Conditions
                    
                    1. Acceptance of Terms
                    By accessing and using the CleanMate app, you agree to be bound by these Terms and Conditions.
                    
                    2. User Registration
                    Users must provide accurate and complete information during registration.
                    
                    3. Service Description
                    CleanMate provides a platform connecting users with cleaning service providers.
                    
                    4. Privacy Policy
                    Your use of CleanMate is also governed by our Privacy Policy.
                    
                    5. Payment Terms
                    All payments are processed securely through our payment providers.
                    
                    6. Cancellation Policy
                    Cancellations must be made at least 24 hours before the scheduled service.
                    
                    7. Liability
                    CleanMate is not liable for any damages or losses incurred during service provision.
                    """)
                .padding()
            }
            .navigationTitle("Terms & Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
