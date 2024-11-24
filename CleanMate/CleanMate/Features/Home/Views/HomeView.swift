import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    welcomeSection
                    
                    // Search Bar
                    searchBar
                    
                    // Popular Services
                    popularServicesSection
                    
                    // All Services
                    allServicesSection
                    
                    // Upcoming Booking
                    if let nextBooking = viewModel.nextBooking {
                        upcomingBookingCard(booking: nextBooking)
                    }
                }
                .padding()
            }
            .navigationTitle("CleanMate")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshData()
            }
            .sheet(item: $viewModel.selectedService) { service in
                BookingView(service: service)
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back,")
                .font(.title2)
            if let name = appState.currentUser?.fullName.components(separatedBy: " ").first {
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search services", text: $viewModel.searchQuery)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var popularServicesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Popular Services")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.popularServices) { service in
                        PopularServiceCard(service: service)
                            .onTapGesture {
                                viewModel.selectedService = service
                            }
                    }
                }
            }
        }
    }
    
    private var allServicesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "All Services")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(viewModel.filteredServices) { service in
                    ServiceCard(service: service)
                        .onTapGesture {
                            viewModel.selectedService = service
                        }
                }
            }
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Button("See All") {
                // Implement see all action
            }
            .foregroundColor(.blue)
        }
    }
    
    private func upcomingBookingCard(booking: Booking) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Upcoming Booking")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "calendar")
                    Text(booking.scheduledDate, style: .date)
                }
                
                HStack {
                    Image(systemName: "clock")
                    Text(booking.scheduledTime.formattedTimeRange)
                }
                
                HStack {
                    Image(systemName: "mappin.circle")
                    Text(booking.address.street)
                }
                
                StatusBadge(status: booking.status)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct PopularServiceCard: View {
    let service: CleaningService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageURL = service.imageURL {
                WebImage(url: URL(string: imageURL))
                    .resizable()
                    .placeholder {
                        Color.gray.opacity(0.3)
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: 200, height: 120)
                    .clipped()
                    .cornerRadius(10)
            }
            
            Text(service.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(service.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Text("From $\(service.basePrice as NSDecimalNumber, formatter: NumberFormatter())")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(width: 200)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct ServiceCard: View {
    let service: CleaningService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: service.category.icon)
                .font(.title)
                .foregroundColor(.blue)
            
            Text(service.name)
                .font(.headline)
                .lineLimit(2)
            
            Text("From $\(service.basePrice as NSDecimalNumber, formatter: NumberFormatter())")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct StatusBadge: View {
    let status: Booking.BookingStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(status.color).opacity(0.2))
            .foregroundColor(Color(status.color))
            .cornerRadius(8)
    }
}

class HomeViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var selectedService: CleaningService?
    @Published var popularServices: [CleaningService] = []
    @Published var allServices: [CleaningService] = []
    @Published var nextBooking: Booking?
    
    private let bookingService = BookingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        bookingService.$services
            .receive(on: DispatchQueue.main)
            .sink { [weak self] services in
                self?.allServices = services
            }
            .store(in: &cancellables)
        
        bookingService.$popularServices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] services in
                self?.popularServices = services
            }
            .store(in: &cancellables)
        
        bookingService.$upcomingBookings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bookings in
                self?.nextBooking = bookings.first
            }
            .store(in: &cancellables)
        
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    var filteredServices: [CleaningService] {
        if searchQuery.isEmpty {
            return allServices
        }
        return allServices.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    @MainActor
    func refreshData() async {
        bookingService.fetchServices()
        if let userId = AuthenticationService.shared.currentUser?.id {
            bookingService.fetchUpcomingBookings(for: userId)
        }
    }
}
