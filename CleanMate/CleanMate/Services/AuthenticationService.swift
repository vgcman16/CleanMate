import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

enum AuthError: LocalizedError {
    case signInFailed(String)
    case signUpFailed(String)
    case signOutFailed(String)
    case userNotFound
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signUpFailed(let message):
            return "Sign up failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .userNotFound:
            return "No user found with this email."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 6 characters long."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published private(set) var user: User?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: AuthError?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAuthStateHandler()
    }
    
    private func setupAuthStateHandler() {
        auth.authStateDidChangePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.isAuthenticated = user != nil
                if let user = user {
                    Task {
                        await self?.fetchUserProfile(for: user)
                    }
                } else {
                    self?.user = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func signIn(
        email: String,
        password: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await auth.signIn(
                withEmail: email,
                password: password
            )
            await fetchUserProfile(for: result.user)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signUp(
        email: String,
        password: String,
        name: String,
        phone: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await auth.createUser(
                withEmail: email,
                password: password
            )
            
            let user = User(
                id: result.user.uid,
                email: email,
                name: name,
                phone: phone
            )
            
            try await createUserProfile(user)
            self.user = user
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try auth.signOut()
            user = nil
            isAuthenticated = false
        } catch {
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }
    
    private func fetchUserProfile(for firebaseUser: FirebaseAuth.User) async {
        do {
            let document = try await db
                .collection("users")
                .document(firebaseUser.uid)
                .getDocument()
            
            if let data = document.data(),
               let name = data["name"] as? String,
               let phone = data["phone"] as? String {
                await MainActor.run {
                    self.user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        name: name,
                        phone: phone
                    )
                }
            }
        } catch {
            self.error = .unknown(error)
        }
    }
    
    private func createUserProfile(_ user: User) async throws {
        try await db
            .collection("users")
            .document(user.id)
            .setData([
                "email": user.email,
                "name": user.name,
                "phone": user.phone,
                "createdAt": Timestamp()
            ])
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        default:
            return .unknown(error)
        }
    }
}
