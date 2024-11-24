import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import PassKit
import Stripe

class PaymentService: ObservableObject {
    static let shared = PaymentService()
    
    private let db = Firestore.firestore()
    @Published var savedPaymentMethods: [SavedPaymentMethod] = []
    @Published var isLoading = false
    
    private init() {
        setupStripe()
        if let userId = AuthenticationService.shared.currentUser?.id {
            fetchSavedPaymentMethods(for: userId)
        }
    }
    
    private func setupStripe() {
        Task {
            do {
                let config = try await fetchStripeConfig()
                StripeAPI.defaultPublishableKey = config.publishableKey
            } catch {
                print("Error setting up Stripe: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchStripeConfig() async throws -> PaymentConfiguration {
        let document = try await db.collection("config")
            .document("stripe")
            .getDocument()
        return try document.data(as: PaymentConfiguration.self)
    }
    
    func fetchSavedPaymentMethods(for userId: String) {
        db.collection("users")
            .document(userId)
            .collection("paymentMethods")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching payment methods: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.savedPaymentMethods = documents.compactMap { try? $0.data(as: SavedPaymentMethod.self) }
            }
    }
    
    func createPaymentIntent(for booking: Booking) async throws -> PaymentIntent {
        isLoading = true
        defer { isLoading = false }
        
        // Convert decimal amount to cents
        let amountInCents = Int(booking.totalPrice * 100)
        
        // Create payment intent in Firestore
        let paymentIntent = PaymentIntent(
            bookingId: booking.id ?? "",
            amount: amountInCents,
            currency: "usd",
            status: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let docRef = db.collection("paymentIntents").document()
        var savedIntent = paymentIntent
        savedIntent.id = docRef.documentID
        
        // Create payment intent on Stripe server
        let data = try await callStripeBackend(
            endpoint: "create-payment-intent",
            body: [
                "amount": amountInCents,
                "currency": "usd",
                "booking_id": booking.id ?? "",
                "payment_intent_id": docRef.documentID
            ]
        )
        
        guard let clientSecret = data["clientSecret"] as? String,
              let stripePaymentIntentId = data["paymentIntentId"] as? String else {
            throw PaymentError.invalidResponse
        }
        
        // Update payment intent with Stripe details
        savedIntent.stripePaymentIntentId = stripePaymentIntentId
        savedIntent.stripeClientSecret = clientSecret
        
        try docRef.setData(from: savedIntent)
        return savedIntent
    }
    
    func handlePaymentCompletion(paymentIntent: STPPaymentIntent) async throws {
        guard let intentId = paymentIntent.stripeId else { return }
        
        // Find our payment intent
        let snapshot = try await db.collection("paymentIntents")
            .whereField("stripePaymentIntentId", isEqualTo: intentId)
            .getDocuments()
        
        guard let document = snapshot.documents.first,
              var intent = try? document.data(as: PaymentIntent.self) else {
            return
        }
        
        // Update status based on Stripe status
        switch paymentIntent.status {
        case .succeeded:
            intent.status = .succeeded
        case .requiresPaymentMethod, .requiresConfirmation, .requiresAction:
            intent.status = .pending
        case .processing:
            intent.status = .processing
        case .canceled:
            intent.status = .canceled
        @unknown default:
            intent.status = .failed
        }
        
        intent.updatedAt = Date()
        
        // Update in Firestore
        try await document.reference.setData(from: intent)
        
        // If payment succeeded, update booking status
        if intent.status == .succeeded {
            try await db.collection("bookings")
                .document(intent.bookingId)
                .updateData([
                    "paymentStatus": Booking.PaymentStatus.paid.rawValue,
                    "status": Booking.BookingStatus.confirmed.rawValue,
                    "updatedAt": Date()
                ])
        }
    }
    
    func setupApplePay() -> Bool {
        StripeAPI.deviceSupportsApplePay() && PKPaymentAuthorizationController.canMakePayments()
    }
    
    private func callStripeBackend(endpoint: String, body: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: "https://your-backend.com/stripe/\(endpoint)") else {
            throw PaymentError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PaymentError.requestFailed
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw PaymentError.invalidResponse
        }
        
        return json
    }
}

enum PaymentError: LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse
    case paymentFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Payment request failed"
        case .invalidResponse:
            return "Invalid response from server"
        case .paymentFailed(let message):
            return message
        }
    }
}
