import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var fullName: String
    var phoneNumber: String
    var profileImageURL: String?
    var addresses: [Address]
    var preferredPaymentMethod: PaymentMethod?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName
        case phoneNumber
        case profileImageURL
        case addresses
        case preferredPaymentMethod
        case createdAt
        case updatedAt
    }
}

struct Address: Codable, Identifiable {
    var id = UUID()
    var street: String
    var unit: String?
    var city: String
    var state: String
    var zipCode: String
    var isDefault: Bool
    var instructions: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case street
        case unit
        case city
        case state
        case zipCode
        case isDefault
        case instructions
    }
}

struct PaymentMethod: Codable, Identifiable {
    var id: String  // Stripe payment method ID
    var type: PaymentType
    var last4: String
    var expiryMonth: Int?
    var expiryYear: Int?
    var isDefault: Bool
    
    enum PaymentType: String, Codable {
        case card
        case applePay
    }
}
