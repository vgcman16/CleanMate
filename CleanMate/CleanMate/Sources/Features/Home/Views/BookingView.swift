import SwiftUI

struct BookingView: View {
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(service: CleaningService) {
        _viewModel = StateObject(wrappedValue: BookingViewModel(service: service))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Date & Time") {
                    DatePicker(
                        "Date",
                        selection: $viewModel.selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    
                    DatePicker(
                        "Time",
                        selection: $viewModel.selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                }
                
                Section("Address") {
                    if let address = viewModel.selectedAddress {
                        Text(address.fullAddress)
                            .foregroundColor(.gray)
                    }
                    
                    Button {
                        viewModel.showAddressSheet = true
                    } label: {
                        if viewModel.selectedAddress == nil {
                            Text("Add Address")
                        } else {
                            Text("Change Address")
                        }
                    }
                }
                
                Section("Number of Rooms") {
                    HStack {
                        Button {
                            viewModel.decrementRooms()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(viewModel.numberOfRooms)")
                            .frame(maxWidth: .infinity)
                        
                        Button {
                            viewModel.incrementRooms()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section("Special Instructions") {
                    TextEditor(text: $viewModel.specialInstructions)
                        .frame(height: 100)
                }
                
                Section {
                    Button {
                        viewModel.showPaymentSheet = true
                    } label: {
                        Text("Continue to Payment")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(viewModel.selectedAddress == nil)
                }
                
                Section("Total Amount") {
                    Text("$\(String(format: "%.2f", viewModel.totalAmount))")
                        .font(.headline)
                }
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
                AddressFormView(address: $viewModel.selectedAddress)
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

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView(
            service: CleaningService(
                id: "1",
                name: "Regular Cleaning",
                description: "Standard cleaning service",
                basePrice: 100,
                imageURL: nil,
                category: .regular,
                isPopular: true,
                createdAt: Date()
            )
        )
    }
}
