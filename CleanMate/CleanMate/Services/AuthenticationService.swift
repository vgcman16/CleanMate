import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var currentUser: User?
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.fetchUser(userId: user.uid)
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            await fetchUser(userId: result.user.uid)
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    func signUp(email: String, password: String, fullName: String, phoneNumber: String) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = User(
                email: email,
                fullName: fullName,
                phoneNumber: phoneNumber,
                addresses: [],
                createdAt: Date(),
                updatedAt: Date()
            )
            try await createUserDocument(user: user, userId: result.user.uid)
        } catch {
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            currentUser = nil
        } catch {
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }
    
    private func createUserDocument(user: User, userId: String) async throws {
        do {
            try await db.collection("users").document(userId).setData(from: user)
        } catch {
            throw AuthError.userCreationFailed(error.localizedDescription)
        }
    }
    
    private func fetchUser(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            let user = try document.data(as: User.self)
            DispatchQueue.main.async {
                self.currentUser = user
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }
}

enum AuthError: LocalizedError {
    case signInFailed(String)
    case signUpFailed(String)
    case signOutFailed(String)
    case userCreationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .signInFailed(let message),
             .signUpFailed(let message),
             .signOutFailed(let message),
             .userCreationFailed(let message):
            return message
        }
    }
}
