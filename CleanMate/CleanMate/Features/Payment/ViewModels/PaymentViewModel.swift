import Combine
import FirebaseAuth
import StripePaymentSheet
import SwiftUI

class PaymentViewModel: ObservableObject {
    @Published var booking: Booking
    @Published var paymentSheet: PaymentSheet?
    @Published var savedPaymentMethods: [SavedPaymentMethod] = []
    @Published var showSavedPaymentMethods = false
    @Published var selectedPaymentMethod: SavedPaymentMethod?
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage: String?
    
    private let paymentService: PaymentService
    private var cancellables = Set<AnyCancellable>()
    
    init(booking: Booking, paymentService: PaymentService = .shared) {
        self.booking = booking
        self.paymentService = paymentService
    }
    
    func preparePaymentSheet() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let paymentIntent = try await paymentService.createPaymentIntent(
                amount: Int(booking.totalAmount * 100),
                currency: "usd"
            )
            
            await MainActor.run {
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "CleanMate"
                configuration.allowsDelayedPaymentMethods = false
                
                paymentSheet = PaymentSheet(
                    paymentIntentClientSecret: paymentIntent.clientSecret,
                    configuration: configuration
                )
            }
            
            await fetchSavedPaymentMethods()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            Task {
                await updateBookingStatus()
            }
        case .failed(let error):
            errorMessage = error.localizedDescription
            showError = true
        case .canceled:
            break
        }
    }
    
    func selectPaymentMethod(_ method: SavedPaymentMethod) {
        selectedPaymentMethod = method
        Task {
            await processPaymentWithSavedMethod()
        }
    }
    
    private func updateBookingStatus() async {
        do {
            try await paymentService.updateBookingPaymentStatus(
                bookingId: booking.id,
                status: .paid
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
    
    private func fetchSavedPaymentMethods() async {
        do {
            let methods = try await paymentService.fetchSavedPaymentMethods()
            
            await MainActor.run {
                savedPaymentMethods = methods
                showSavedPaymentMethods = !methods.isEmpty
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func processPaymentWithSavedMethod() async {
        guard let method = selectedPaymentMethod else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await paymentService.processPayment(
                amount: Int(booking.totalAmount * 100),
                currency: "usd",
                paymentMethodId: method.id,
                bookingId: booking.id
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
}
