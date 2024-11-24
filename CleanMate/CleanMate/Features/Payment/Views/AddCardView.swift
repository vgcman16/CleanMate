import Combine
import FirebaseAuth
import StripePaymentSheet
import Stripe
import SwiftUI

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
                        TextField("MM/YY", text: $viewModel.expiry)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                        
                        TextField("CVC", text: $viewModel.cvc)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                    }
                    
                    TextField("Cardholder Name", text: $viewModel.name)
                        .textContentType(.name)
                } header: {
                    Text("Card Details")
                }
                
                Section {
                    Toggle("Save for Future Use", isOn: $viewModel.saveCard)
                } header: {
                    Text("Options")
                }
                
                Section {
                    Button(action: addCard) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Add Card")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
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
            .alert(
                "Error",
                isPresented: $viewModel.showError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .alert(
                "Success",
                isPresented: $viewModel.showSuccess
            ) {
                Button("OK", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Card added successfully!")
            }
        }
    }
    
    private func addCard() {
        Task {
            await viewModel.addCard()
        }
    }
}

class AddCardViewModel: ObservableObject {
    @Published var cardNumber = ""
    @Published var expiry = ""
    @Published var cvc = ""
    @Published var name = ""
    @Published var saveCard = true
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage: String?
    
    var isValid: Bool {
        !cardNumber.isEmpty &&
        !expiry.isEmpty &&
        !cvc.isEmpty &&
        !name.isEmpty &&
        cardNumber.count >= 16 &&
        expiry.count >= 5 &&
        cvc.count >= 3
    }
    
    func addCard() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let card = try await PaymentService.shared.addCard(
                number: cardNumber,
                expiry: expiry,
                cvc: cvc,
                name: name,
                save: saveCard
            )
            
            await MainActor.run {
                showSuccess = true
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func saveCardDetails() async -> SavedPaymentMethod? {
        do {
            let params = STPPaymentMethodCardParams()
            params.number = cardNumber
            params.expMonth = NSNumber(value: Int(expiry.components(separatedBy: "/")[0]) ?? 0)
            params.expYear = NSNumber(value: Int(expiry.components(separatedBy: "/")[1]) ?? 0)
            params.cvc = cvc
            
            let billingDetails = STPPaymentMethodBillingDetails()
            billingDetails.name = name
            
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
                expiryMonth: Int(expiry.components(separatedBy: "/")[0]),
                expiryYear: Int(expiry.components(separatedBy: "/")[1]),
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
