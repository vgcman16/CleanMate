import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import Stripe

struct PaymentIntent: Codable, Identifiable {
    @DocumentID var id: String?
    var bookingId: String
    var amount: Int // Amount in cents
    var currency: String
    var status: PaymentStatus
    var stripePaymentIntentId: String?
    var stripeClientSecret: String?
    var createdAt: Date
    var updatedAt: Date
    
    enum PaymentStatus: String, Codable {
        case pending
        case processing
        case succeeded
        case failed
        case canceled
        
        var displayText: String {
            switch self {
            case .pending: return "Pending"
            case .processing: return "Processing"
            case .succeeded: return "Paid"
            case .failed: return "Failed"
            case .canceled: return "Canceled"
            }
        }
        
        var color: String {
            switch self {
            case .pending: return "yellow"
            case .processing: return "blue"
            case .succeeded: return "green"
            case .failed: return "red"
            case .canceled: return "gray"
            }
        }
    }
}

struct SavedPaymentMethod: Codable, Identifiable {
    var id: String // Stripe payment method ID
    var type: PaymentMethodType
    var last4: String
    var expiryMonth: Int?
    var expiryYear: Int?
    var brand: String?
    var isDefault: Bool
    
    enum PaymentMethodType: String, Codable {
        case card
        case applePay
        
        var displayText: String {
            switch self {
            case .card: return "Credit Card"
            case .applePay: return "Apple Pay"
            }
        }
        
        var icon: String {
            switch self {
            case .card: return "creditcard.fill"
            case .applePay: return "apple.logo"
            }
        }
    }
    
    var displayName: String {
        switch type {
        case .card:
            let brandName = brand?.capitalized ?? "Card"
            return "\(brandName) •••• \(last4)"
        case .applePay:
            return "Apple Pay"
        }
    }
}

struct PaymentConfiguration: Codable {
    var publishableKey: String
    var merchantIdentifier: String
}
