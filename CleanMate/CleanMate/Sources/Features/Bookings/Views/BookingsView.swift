import SwiftUI

struct BookingsView: View {
    @StateObject private var viewModel = BookingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.upcomingBookings.isEmpty &&
                    viewModel.completedBookings.isEmpty &&
                    viewModel.cancelledBookings.isEmpty {
                    Text("No bookings found")
                        .foregroundColor(.gray)
                } else {
                    if !viewModel.upcomingBookings.isEmpty {
                        Section("Upcoming") {
                            ForEach(viewModel.upcomingBookings) { booking in
                                BookingRow(booking: booking) {
                                    Task {
                                        await viewModel.cancelBooking(booking.id ?? "")
                                    }
                                }
                            }
                        }
                    }
                    
                    if !viewModel.completedBookings.isEmpty {
                        Section("Completed") {
                            ForEach(viewModel.completedBookings) { booking in
                                BookingRow(booking: booking)
                            }
                        }
                    }
                    
                    if !viewModel.cancelledBookings.isEmpty {
                        Section("Cancelled") {
                            ForEach(viewModel.cancelledBookings) { booking in
                                BookingRow(booking: booking)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bookings")
            .refreshable {
                await viewModel.fetchBookings()
            }
            .task {
                await viewModel.fetchBookings()
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

struct BookingRow: View {
    let booking: Booking
    var onCancel: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(booking.scheduledDate, style: .date)
                    .font(.headline)
                Spacer()
                Text(booking.status.rawValue)
                    .foregroundColor(Color(booking.status.color))
            }
            
            Text(booking.scheduledTime.formattedTimeRange)
                .foregroundColor(.gray)
            
            Text(booking.address.fullAddress)
                .foregroundColor(.gray)
            
            if booking.status == .upcoming, let onCancel = onCancel {
                Button(role: .destructive) {
                    onCancel()
                } label: {
                    Text("Cancel Booking")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct BookingsView_Previews: PreviewProvider {
    static var previews: some View {
        BookingsView()
    }
}
