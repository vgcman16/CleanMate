import Foundation
import FirebaseFirestoreSwift

struct CleaningService: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let description: String
    let basePrice: Double
    let imageURL: String?
    let category: ServiceCategory
    let isPopular: Bool
    let createdAt: Date
    
    enum ServiceCategory: String, Codable {
        case regular = "Regular Cleaning"
        case deep = "Deep Cleaning"
        case move = "Move In/Out Cleaning"
        case office = "Office Cleaning"
        
        var icon: String {
            switch self {
            case .regular: return "house.circle"
            case .deep: return "sparkles.circle"
            case .move: return "box.truck"
            case .office: return "building.2"
            }
        }
    }
}

struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let serviceId: String
    let scheduledDate: Date
    let scheduledTime: TimeSlot
    let status: BookingStatus
    let address: Address
    let createdAt: Date
    
    enum BookingStatus: String, Codable {
        case upcoming = "Upcoming"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var color: String {
            switch self {
            case .upcoming: return "blue"
            case .inProgress: return "orange"
            case .completed: return "green"
            case .cancelled: return "red"
            }
        }
    }
}

struct TimeSlot: Codable {
    let start: Date
    let end: Date
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct Address: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    
    var fullAddress: String {
        "\(street), \(city), \(state) \(zipCode)"
    }
}
