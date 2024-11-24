import Combine
import Foundation
import FirebaseAuth
import StripePaymentSheet
import SwiftUI

@MainActor
final class PaymentViewModel: ObservableObject {
    @Published private(set) var paymentSheet: PaymentSheet?
    @Published private(set) var paymentResult: PaymentSheetResult?
    @Published private(set) var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let paymentService: PaymentService
    private var cancellables = Set<AnyCancellable>()
    
    init(paymentService: PaymentService = .shared) {
        self.paymentService = paymentService
    }
    
    func preparePayment(for booking: Booking) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let clientSecret = try await paymentService.createPaymentIntent(
                amount: Int(booking.totalAmount * 100),
                currency: "usd"
            )
            
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "CleanMate"
            configuration.allowsDelayedPaymentMethods = false
            
            paymentSheet = PaymentSheet(
                paymentIntentClientSecret: clientSecret,
                configuration: configuration
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        paymentResult = result
        
        switch result {
        case .completed:
            break
        case .canceled:
            errorMessage = "Payment was canceled"
            showError = true
        case .failed(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func resetPaymentState() {
        paymentSheet = nil
        paymentResult = nil
        errorMessage = ""
        showError = false
    }
}
