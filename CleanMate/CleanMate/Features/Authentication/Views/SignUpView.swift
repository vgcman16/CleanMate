import Combine
import FirebaseAuth
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phone = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 16) {
                        TextField(
                            "Full Name",
                            text: $name
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.name)
                        
                        TextField(
                            "Email",
                            text: $email
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        
                        TextField(
                            "Phone",
                            text: $phone
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        
                        SecureField(
                            "Password",
                            text: $password
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                        
                        SecureField(
                            "Confirm Password",
                            text: $confirmPassword
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            await signUp()
                        }
                    } label: {
                        if isLoading {
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
                    .disabled(isLoading)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func signUp() async {
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
            dismiss()
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
        
        if phone.isEmpty {
            errorMessage = "Please enter your phone number"
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
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthenticationService.shared)
    }
}
