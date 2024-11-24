import Combine
import FirebaseAuth
import PassKit
import Stripe
import StripePaymentSheet
import SwiftUI

struct PaymentView: View {
    @StateObject private var viewModel: PaymentViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    let booking: Booking
    
    init(booking: Booking) {
        _viewModel = StateObject(wrappedValue: PaymentViewModel(booking: booking))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Payment Summary
                    PaymentSummaryCard(booking: booking)
                        .padding(.horizontal)
                    
                    // Saved Payment Methods
                    if !viewModel.savedPaymentMethods.isEmpty {
                        SavedPaymentMethodsSection(
                            methods: viewModel.savedPaymentMethods,
                            selectedMethod: $viewModel.selectedPaymentMethod
                        )
                    }
                    
                    // Add New Card Button
                    Button(action: { viewModel.showAddCard = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Card")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    
                    // Apple Pay Button
                    if viewModel.isApplePayAvailable {
                        ApplePayButton()
                            .frame(height: 45)
                            .padding(.horizontal)
                    }
                    
                    // Pay Button
                    Button(action: { Task { await viewModel.processPayment(for: booking) } }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Pay \(booking.totalPrice.formatted(.currency(code: "USD")))")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading || viewModel.selectedPaymentMethod == nil)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss.callAsFunction()
                    }
                }
            }
            .alert("Payment Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $viewModel.showAddCard) {
                AddCardView { paymentMethod in
                    viewModel.selectedPaymentMethod = paymentMethod
                    viewModel.showAddCard = false
                }
            }
        }
    }
}

struct PaymentSummaryCard: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.headline)
            
            Divider()
            
            HStack {
                Text("Service")
                Spacer()
                Text(booking.service.name)
            }
            
            HStack {
                Text("Date")
                Spacer()
                Text(booking.date.formatted(date: .medium, time: .short))
            }
            
            if let rooms = booking.numberOfRooms {
                HStack {
                    Text("Rooms")
                    Spacer()
                    Text("\(rooms)")
                }
            }
            
            Divider()
            
            HStack {
                Text("Total")
                    .fontWeight(.semibold)
                Spacer()
                Text(booking.totalPrice.formatted(.currency(code: "USD")))
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SavedPaymentMethodsSection: View {
    let methods: [SavedPaymentMethod]
    @Binding var selectedMethod: SavedPaymentMethod?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Payment Methods")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(methods) { method in
                PaymentMethodRow(
                    method: method,
                    isSelected: selectedMethod?.id == method.id
                )
                .onTapGesture {
                    selectedMethod = method
                }
            }
        }
    }
}

struct PaymentMethodRow: View {
    let method: SavedPaymentMethod
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: method.type.icon)
                .foregroundColor(.blue)
            
            Text(method.displayName)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct ApplePayButton: View {
    var body: some View {
        PKPaymentButton(type: .plain, style: .black)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(booking: Booking.preview)
    }
}
