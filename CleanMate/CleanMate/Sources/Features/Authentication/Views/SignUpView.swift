import SwiftUI

struct SignUpView: View {
    @StateObject
    private var viewModel = SignUpViewModel()
    
    @Environment(\.dismiss)
    private var dismiss
    
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
                        CustomTextField(
                            text: $viewModel.name,
                            placeholder: "Full Name",
                            icon: "person",
                            textContentType: .name
                        )
                        
                        CustomTextField(
                            text: $viewModel.email,
                            placeholder: "Email",
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress,
                            autocapitalization: .none
                        )
                        
                        CustomTextField(
                            text: $viewModel.phone,
                            placeholder: "Phone",
                            icon: "phone",
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber
                        )
                        
                        CustomSecureField(
                            text: $viewModel.password,
                            placeholder: "Password",
                            icon: "lock"
                        )
                        
                        CustomSecureField(
                            text: $viewModel.confirmPassword,
                            placeholder: "Confirm Password",
                            icon: "lock"
                        )
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            await viewModel.signUp()
                            if !viewModel.showError {
                                dismiss()
                            }
                        }
                    } label: {
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
                    .disabled(viewModel.isLoading)
                    
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
