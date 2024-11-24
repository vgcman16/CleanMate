import XCTest
import FirebaseAuth
import FirebaseFirestore
@testable import CleanMate

// MARK: - Test Data Factories

extension CleaningService {
    static func mock(
        id: String = "mock-service-id",
        name: String = "Standard Cleaning",
        description: String = "A thorough cleaning of your home",
        basePrice: Double = 50.0,
        imageURL: String? = nil,
        category: ServiceCategory = .regular,
        isPopular: Bool = true,
        createdAt: Date = Date()
    ) -> CleaningService {
        CleaningService(
            id: id,
            name: name,
            description: description,
            basePrice: basePrice,
            imageURL: imageURL,
            category: category,
            isPopular: isPopular,
            createdAt: createdAt
        )
    }
}

extension Booking {
    static func mock(
        id: String = "mock-booking-id",
        userId: String = "mock-user-id",
        serviceId: String = "mock-service-id",
        scheduledDate: Date = Date(),
        scheduledTime: TimeSlot = .mock(),
        status: BookingStatus = .upcoming,
        address: Address = .mock(),
        createdAt: Date = Date()
    ) -> Booking {
        Booking(
            id: id,
            userId: userId,
            serviceId: serviceId,
            scheduledDate: scheduledDate,
            scheduledTime: scheduledTime,
            status: status,
            address: address,
            createdAt: createdAt
        )
    }
}

extension TimeSlot {
    static func mock(
        start: Date = Date(),
        end: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    ) -> TimeSlot {
        TimeSlot(start: start, end: end)
    }
}

extension Address {
    static func mock(
        street: String = "123 Main St",
        city: String = "San Francisco",
        state: String = "CA",
        zipCode: String = "94105",
        country: String = "United States"
    ) -> Address {
        Address(
            street: street,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country
        )
    }
}

// MARK: - Mock Firebase Classes

class MockFirestore {
    var collections: [String: MockCollectionReference] = [:]
    var error: Error?
    
    func collection(_ path: String) -> MockCollectionReference {
        if let collection = collections[path] {
            return collection
        }
        let collection = MockCollectionReference()
        collections[path] = collection
        return collection
    }
}

class MockCollectionReference {
    var documents: [String: MockDocumentReference] = [:]
    var error: Error?
    var queryResults: [MockDocumentSnapshot] = []
    
    func document(_ path: String) -> MockDocumentReference {
        if let document = documents[path] {
            return document
        }
        let document = MockDocumentReference()
        documents[path] = document
        return document
    }
    
    func addDocument(data: [String: Any]) throws -> MockDocumentReference {
        let document = MockDocumentReference()
        document.data = data
        return document
    }
    
    func whereField(_ field: String, isEqualTo: Any) -> MockQuery {
        return MockQuery(queryResults: queryResults)
    }
    
    func getDocuments() async throws -> MockQuerySnapshot {
        if let error = error {
            throw error
        }
        return MockQuerySnapshot(documents: queryResults)
    }
}

class MockDocumentReference {
    var data: [String: Any]?
    var error: Error?
    
    func setData(_ data: [String: Any]) async throws {
        if let error = error {
            throw error
        }
        self.data = data
    }
    
    func updateData(_ data: [String: Any]) async throws {
        if let error = error {
            throw error
        }
        self.data?.merge(data) { _, new in new }
    }
}

class MockQuery {
    var queryResults: [MockDocumentSnapshot]
    
    init(queryResults: [MockDocumentSnapshot]) {
        self.queryResults = queryResults
    }
    
    func getDocuments() async throws -> MockQuerySnapshot {
        return MockQuerySnapshot(documents: queryResults)
    }
}

class MockQuerySnapshot {
    var documents: [MockDocumentSnapshot]
    
    init(documents: [MockDocumentSnapshot]) {
        self.documents = documents
    }
}

class MockDocumentSnapshot {
    var data: [String: Any]
    
    init(data: [String: Any]) {
        self.data = data
    }
    
    func data() -> [String: Any] {
        return data
    }
}
