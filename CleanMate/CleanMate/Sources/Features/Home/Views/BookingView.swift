import SwiftUI

struct BookingView: View {
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(service: CleaningService) {
        _viewModel = StateObject(wrappedValue: BookingViewModel(service: service))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ServiceHeader(service: service)
                    
                    DatePicker(
                        "Select Date",
                        selection: $viewModel.selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    
                    DatePicker(
                        "Select Time",
                        selection: $viewModel.selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    
                    AddressSelector(
                        selectedAddress: $viewModel.selectedAddress,
                        showAddressSheet: $viewModel.showAddressSheet
                    )
                    
                    RoomSelector(viewModel: viewModel)
                    
                    InstructionsField(instructions: $viewModel.specialInstructions)
                    
                    PriceSummary(
                        numberOfRooms: viewModel.numberOfRooms,
                        totalAmount: viewModel.totalAmount
                    )
                    
                    Button {
                        Task {
                            if await viewModel.createBooking() {
                                viewModel.showPaymentSheet = true
                            }
                        }
                    } label: {
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
                    .disabled(viewModel.isLoading || viewModel.selectedAddress == nil)
                }
                .padding()
            }
            .navigationTitle("Book Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddressSheet) {
                AddressFormView(
                    selectedAddress: $viewModel.selectedAddress,
                    isPresented: $viewModel.showAddressSheet
                )
            }
            .sheet(isPresented: $viewModel.showPaymentSheet) {
                PaymentView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

private struct ServiceHeader: View {
    let service: CleaningService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(service.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(service.description)
                .foregroundColor(.gray)
            
            Text("$\(service.basePrice, specifier: "%.2f") per room")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RoomSelector: View {
    @ObservedObject var viewModel: BookingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Number of Rooms")
                .font(.headline)
            
            HStack {
                Button {
                    viewModel.decrementRooms()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .imageScale(.large)
                }
                
                Text("\(viewModel.numberOfRooms)")
                    .font(.title2)
                    .frame(width: 50)
                
                Button {
                    viewModel.incrementRooms()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
            .foregroundColor(.blue)
        }
    }
}

private struct InstructionsField: View {
    @Binding var instructions: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Special Instructions")
                .font(.headline)
            
            TextEditor(text: $instructions)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

private struct PriceSummary: View {
    let numberOfRooms: Int
    let totalAmount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price Summary")
                .font(.headline)
            
            HStack {
                Text("Cleaning Service (\(numberOfRooms) rooms)")
                Spacer()
                Text("$\(totalAmount, specifier: "%.2f")")
            }
            .foregroundColor(.gray)
            
            Divider()
            
            HStack {
                Text("Total Amount")
                    .fontWeight(.bold)
                Spacer()
                Text("$\(totalAmount, specifier: "%.2f")")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView(
            service: CleaningService(
                id: "1",
                name: "Standard Cleaning",
                description: "A thorough cleaning of your home",
                basePrice: 50.0,
                imageURL: nil,
                category: .regular,
                isPopular: true,
                createdAt: Date()
            )
        )
    }
}
