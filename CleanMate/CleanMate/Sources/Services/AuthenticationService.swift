import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var userData: UserData?
    
    private let db = Firestore.firestore()
    
    private init() {
        setupAuthStateHandler()
    }
    
    private func setupAuthStateHandler() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = user != nil
            
            if let userId = user?.uid {
                self?.fetchUserData(userId: userId)
            } else {
                self?.userData = nil
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        currentUser = result.user
        isAuthenticated = true
    }
    
    func signUp(email: String, password: String, name: String, phone: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        currentUser = result.user
        isAuthenticated = true
        
        let userData = UserData(
            id: result.user.uid,
            email: email,
            name: name,
            phone: phone
        )
        
        try await saveUserData(userData)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
        userData = nil
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    private func saveUserData(_ userData: UserData) async throws {
        try await db.collection("users")
            .document(userData.id)
            .setData(userData.asDictionary())
    }
    
    private func fetchUserData(userId: String) {
        db.collection("users")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data() else {
                    print("Error fetching user data: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                
                self?.userData = UserData(
                    id: userId,
                    email: data["email"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    phone: data["phone"] as? String ?? ""
                )
            }
    }
}

struct UserData {
    let id: String
    let email: String
    let name: String
    let phone: String
    
    func asDictionary() -> [String: Any] {
        [
            "email": email,
            "name": name,
            "phone": phone
        ]
    }
}
