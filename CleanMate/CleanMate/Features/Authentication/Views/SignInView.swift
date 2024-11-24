import Combine
import FirebaseAuth
import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                
                Text("Welcome Back!")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField(
                        "Email",
                        text: $email
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    SecureField(
                        "Password",
                        text: $password
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        await signIn()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
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
                
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
            }
            .padding()
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
    
    private func signIn() async {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.signIn(
                email: email,
                password: password
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @State private var isSecure = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthenticationService.shared)
    }
}
