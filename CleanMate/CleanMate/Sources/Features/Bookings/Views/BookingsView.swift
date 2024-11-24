import SwiftUI

struct BookingsView: View {
    @StateObject private var viewModel = BookingsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.bookings.isEmpty {
                    EmptyBookingsView()
                } else {
                    List {
                        ForEach(viewModel.bookings) { booking in
                            BookingCell(booking: booking)
                        }
                    }
                }
            }
            .navigationTitle("My Bookings")
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

private struct EmptyBookingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Bookings Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your upcoming bookings will appear here")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct BookingCell: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(booking.scheduledDate, style: .date)
                        .font(.headline)
                    
                    Text(booking.scheduledTime.formattedTimeRange)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadge(status: booking.status)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                    Text(booking.address.street)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.blue)
                    Text("\(booking.address.city), \(booking.address.state)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct BookingsView_Previews: PreviewProvider {
    static var previews: some View {
        BookingsView()
    }
}
