import Foundation
import FirebaseFirestoreSwift

struct CleaningService: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var basePrice: Decimal
    var estimatedDuration: Int  // in minutes
    var category: ServiceCategory
    var includedTasks: [String]
    var imageURL: String?
    var isPopular: Bool
    var isAvailable: Bool
    var priceUnit: PriceUnit
    var minimumRooms: Int
    
    enum ServiceCategory: String, Codable {
        case regular = "Regular Cleaning"
        case deep = "Deep Cleaning"
        case move = "Move In/Out Cleaning"
        case office = "Office Cleaning"
        case special = "Special Services"
        
        var icon: String {
            switch self {
            case .regular: return "house.fill"
            case .deep: return "sparkles.fill"
            case .move: return "box.truck.fill"
            case .office: return "building.2.fill"
            case .special: return "star.fill"
            }
        }
    }
    
    enum PriceUnit: String, Codable {
        case perRoom = "per room"
        case perHour = "per hour"
        case fixed = "fixed price"
    }
}

struct Booking: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var serviceId: String
    var address: Address
    var scheduledDate: Date
    var scheduledTime: TimeSlot
    var status: BookingStatus
    var numberOfRooms: Int
    var specialInstructions: String?
    var totalPrice: Decimal
    var paymentStatus: PaymentStatus
    var createdAt: Date
    var updatedAt: Date
    
    enum BookingStatus: String, Codable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var color: String {
            switch self {
            case .pending: return "yellow"
            case .confirmed: return "blue"
            case .inProgress: return "purple"
            case .completed: return "green"
            case .cancelled: return "red"
            }
        }
    }
    
    enum PaymentStatus: String, Codable {
        case pending = "Pending"
        case authorized = "Authorized"
        case paid = "Paid"
        case refunded = "Refunded"
        case failed = "Failed"
    }
}

struct TimeSlot: Codable, Identifiable {
    var id = UUID()
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}
