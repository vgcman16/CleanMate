import Combine
import SwiftUI

struct BookingView: View {
    let service: CleaningService
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(service: CleaningService) {
        self.service = service
        _viewModel = StateObject(wrappedValue: BookingViewModel(service: service))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Service Details
                    serviceDetailsSection
                    
                    // Address Selection
                    addressSection
                    
                    // Date and Time Selection
                    dateTimeSection
                    
                    // Room Count Selection (if applicable)
                    if service.priceUnit == .perRoom {
                        roomCountSection
                    }
                    
                    // Special Instructions
                    instructionsSection
                    
                    // Price Breakdown
                    priceSection
                    
                    // Book Now Button
                    bookButton
                }
                .padding()
            }
            .navigationTitle("Book Service")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Your booking has been confirmed!")
            }
        }
    }
    
    private var serviceDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(service.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(service.description)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "clock")
                Text("Estimated duration: \(service.estimatedDuration) minutes")
            }
            .foregroundColor(.gray)
            
            Divider()
            
            Text("Included Tasks:")
                .font(.headline)
            
            ForEach(service.includedTasks, id: \.self) { task in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(task)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Address")
                .font(.headline)
            
            Picker("Address", selection: $viewModel.selectedAddressIndex) {
                ForEach(Array(viewModel.addresses.enumerated()), id: \.element.id) { index, address in
                    VStack(alignment: .leading) {
                        Text(address.street)
                        if let unit = address.unit {
                            Text("Unit \(unit)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tag(index)
                }
            }
            .pickerStyle(.menu)
            
            Button("Add New Address") {
                // Implement add address action
            }
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Date & Time")
                .font(.headline)
            
            DatePicker("Date",
                      selection: $viewModel.selectedDate,
                      in: Date()...,
                      displayedComponents: .date)
            
            if !viewModel.availableTimeSlots.isEmpty {
                Picker("Time", selection: $viewModel.selectedTimeSlotIndex) {
                    ForEach(Array(viewModel.availableTimeSlots.enumerated()), id: \.element.id) { index, slot in
                        Text(slot.formattedTimeRange)
                            .tag(index)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Text("No available time slots for selected date")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var roomCountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Number of Rooms")
                .font(.headline)
            
            Stepper("Rooms: \(viewModel.numberOfRooms)", value: $viewModel.numberOfRooms, in: service.minimumRooms...10)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Special Instructions")
                .font(.headline)
            
            TextEditor(text: $viewModel.specialInstructions)
                .frame(height: 100)
                .padding(5)
                .background(Color(.systemBackground))
                .cornerRadius(5)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Price Breakdown")
                .font(.headline)
            
            HStack {
                Text("Service Price")
                Spacer()
                Text("$\(viewModel.totalPrice as NSDecimalNumber, formatter: NumberFormatter())")
            }
            
            if service.priceUnit == .perRoom {
                HStack {
                    Text("\(viewModel.numberOfRooms) rooms")
                    Spacer()
                    Text("$\(service.basePrice as NSDecimalNumber, formatter: NumberFormatter()) per room")
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var bookButton: some View {
        Button(action: {
            Task {
                await viewModel.createBooking()
            }
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Book Now")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(!viewModel.isValid || viewModel.isLoading)
    }
}

class BookingViewModel: ObservableObject {
    let service: CleaningService
    
    @Published var selectedDate = Date()
    @Published var selectedTimeSlotIndex = 0
    @Published var selectedAddressIndex = 0
    @Published var numberOfRooms: Int
    @Published var specialInstructions = ""
    @Published var availableTimeSlots: [TimeSlot] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""
    
    private let bookingService = BookingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var addresses: [Address] {
        AuthenticationService.shared.currentUser?.addresses ?? []
    }
    
    var totalPrice: Decimal {
        bookingService.calculatePrice(service: service, numberOfRooms: numberOfRooms)
    }
    
    var isValid: Bool {
        !addresses.isEmpty &&
        !availableTimeSlots.isEmpty &&
        (service.priceUnit != .perRoom || numberOfRooms >= service.minimumRooms)
    }
    
    init(service: CleaningService) {
        self.service = service
        self.numberOfRooms = service.minimumRooms
        
        setupSubscriptions()
        fetchTimeSlots()
    }
    
    private func setupSubscriptions() {
        $selectedDate
            .sink { [weak self] _ in
                self?.fetchTimeSlots()
            }
            .store(in: &cancellables)
    }
    
    private func fetchTimeSlots() {
        Task {
            do {
                let slots = try await bookingService.getAvailableTimeSlots(
                    for: selectedDate,
                    serviceId: service.id ?? ""
                )
                await MainActor.run {
                    availableTimeSlots = slots
                    if slots.isEmpty {
                        selectedTimeSlotIndex = 0
                    }
                }
            } catch {
                print("Error fetching time slots: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func createBooking() async {
        guard isValid,
              let userId = AuthenticationService.shared.currentUser?.id,
              let serviceId = service.id else {
            return
        }
        
        isLoading = true
        
        let booking = Booking(
            userId: userId,
            serviceId: serviceId,
            address: addresses[selectedAddressIndex],
            scheduledDate: selectedDate,
            scheduledTime: availableTimeSlots[selectedTimeSlotIndex],
            status: .pending,
            numberOfRooms: numberOfRooms,
            specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions,
            totalPrice: totalPrice,
            paymentStatus: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            _ = try await bookingService.createBooking(booking)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}
