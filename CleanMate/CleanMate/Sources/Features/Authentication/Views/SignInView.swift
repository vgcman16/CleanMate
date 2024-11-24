import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                    CustomTextField(
                        text: $viewModel.email,
                        placeholder: "Email",
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .none
                    )
                    
                    CustomSecureField(
                        text: $viewModel.password,
                        placeholder: "Password",
                        icon: "lock"
                    )
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        await viewModel.signIn()
                        if !viewModel.showError {
                            dismiss()
                        }
                    }
                } label: {
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
                
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
