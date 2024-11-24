import Foundation
import Combine
import Stripe

class PaymentViewModel: ObservableObject {
    @Published var savedPaymentMethods: [SavedPaymentMethod] = []
    @Published var selectedPaymentMethod: SavedPaymentMethod?
    @Published var isLoading = false
    @Published var showError = false
    @Published var showAddCard = false
    @Published var errorMessage: String?
    
    private let paymentService = PaymentService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isApplePayAvailable: Bool {
        paymentService.setupApplePay()
    }
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        paymentService.$savedPaymentMethods
            .assign(to: &$savedPaymentMethods)
        
        paymentService.$isLoading
            .assign(to: &$isLoading)
    }
    
    func processPayment(for booking: Booking) async {
        do {
            isLoading = true
            let paymentIntent = try await paymentService.createPaymentIntent(for: booking)
            
            guard let clientSecret = paymentIntent.stripeClientSecret else {
                throw PaymentError.invalidResponse
            }
            
            let paymentSheet = PaymentSheet(
                paymentIntentClientSecret: clientSecret,
                configuration: PaymentSheet.Configuration()
            )
            
            await MainActor.run {
                paymentSheet.present(from: UIApplication.shared.windows.first?.rootViewController ?? UIViewController()) { result in
                    Task {
                        switch result {
                        case .completed:
                            // Handle successful payment
                            if let paymentIntent = try? await StripeAPI.PaymentIntent.get(clientSecret: clientSecret) {
                                try? await self.paymentService.handlePaymentCompletion(paymentIntent: paymentIntent)
                            }
                        case .failed(let error):
                            await MainActor.run {
                                self.errorMessage = error.localizedDescription
                                self.showError = true
                            }
                        case .canceled:
                            await MainActor.run {
                                self.errorMessage = "Payment was canceled"
                                self.showError = true
                            }
                        }
                        
                        await MainActor.run {
                            self.isLoading = false
                        }
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isLoading = false
            }
        }
    }
}
