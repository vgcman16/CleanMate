import SwiftUI
import Stripe

struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AddCardViewModel()
    let onSave: (SavedPaymentMethod) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Card Number", text: $viewModel.cardNumber)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        TextField("MM", text: $viewModel.expiryMonth)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        
                        Text("/")
                        
                        TextField("YY", text: $viewModel.expiryYear)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        
                        Spacer()
                        
                        TextField("CVC", text: $viewModel.cvc)
                            .keyboardType(.numberPad)
                            .frame(width: 70)
                    }
                } header: {
                    Text("Card Details")
                }
                
                Section {
                    Toggle("Save Card", isOn: $viewModel.saveCard)
                }
                
                if viewModel.saveCard {
                    Section {
                        TextField("Name on Card", text: $viewModel.cardholderName)
                            .textContentType(.name)
                    }
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            if let paymentMethod = await viewModel.saveCardDetails() {
                                onSave(paymentMethod)
                            }
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
}

class AddCardViewModel: ObservableObject {
    @Published var cardNumber = ""
    @Published var expiryMonth = ""
    @Published var expiryYear = ""
    @Published var cvc = ""
    @Published var cardholderName = ""
    @Published var saveCard = true
    @Published var showError = false
    @Published var errorMessage: String?
    
    var isValid: Bool {
        !cardNumber.isEmpty &&
        !expiryMonth.isEmpty &&
        !expiryYear.isEmpty &&
        !cvc.isEmpty &&
        (!saveCard || !cardholderName.isEmpty)
    }
    
    func saveCardDetails() async -> SavedPaymentMethod? {
        do {
            let params = STPPaymentMethodCardParams()
            params.number = cardNumber
            params.expMonth = NSNumber(value: Int(expiryMonth) ?? 0)
            params.expYear = NSNumber(value: Int(expiryYear) ?? 0)
            params.cvc = cvc
            
            let billingDetails = STPPaymentMethodBillingDetails()
            billingDetails.name = cardholderName
            
            let paymentMethodParams = STPPaymentMethodParams(
                card: params,
                billingDetails: billingDetails,
                metadata: nil
            )
            
            let paymentMethod = try await STPPaymentMethod.create(with: paymentMethodParams)
            
            // Convert to our model
            return SavedPaymentMethod(
                id: paymentMethod.stripeId ?? "",
                type: .card,
                last4: paymentMethod.card?.last4 ?? "",
                expiryMonth: Int(expiryMonth),
                expiryYear: Int(expiryYear),
                brand: paymentMethod.card?.brand.description,
                isDefault: false
            )
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
            return nil
        }
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView { _ in }
    }
}
