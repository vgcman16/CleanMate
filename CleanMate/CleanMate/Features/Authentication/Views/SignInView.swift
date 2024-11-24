import SwiftUI
import Combine

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and Welcome Text
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("Welcome Back!")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Input Fields
                VStack(spacing: 15) {
                    CustomTextField(text: $viewModel.email,
                                 placeholder: "Email",
                                 icon: "envelope.fill")
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    CustomSecureField(text: $viewModel.password,
                                    placeholder: "Password",
                                    icon: "lock.fill")
                        .textContentType(.password)
                }
                .padding(.horizontal)
                
                // Forgot Password
                Button("Forgot Password?") {
                    viewModel.forgotPassword()
                }
                .foregroundColor(.blue)
                .padding(.top, 5)
                
                // Sign In Button
                Button(action: {
                    Task {
                        await viewModel.signIn()
                    }
                }) {
                    if viewModel.isLoading {
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
                .disabled(viewModel.isLoading)
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Sign Up", destination: SignUpView())
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func signIn() async {
        guard !email.isEmpty && !password.isEmpty else {
            showError(message: "Please fill in all fields")
            return
        }
        
        isLoading = true
        do {
            try await AuthenticationService.shared.signIn(email: email, password: password)
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    func forgotPassword() {
        // Implement password reset logic
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
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
