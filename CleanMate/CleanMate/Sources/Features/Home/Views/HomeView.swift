import Combine
import FirebaseAuth
import FirebaseFirestore
import SDWebImage
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = authService.user {
                        Text("Welcome, \(user.name)!")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    SearchBar(
                        text: $viewModel.searchText,
                        placeholder: "Search services..."
                    )
                    
                    if !viewModel.popularServices.isEmpty {
                        ServiceCarousel(
                            title: "Popular Services",
                            services: viewModel.popularServices
                        )
                    }
                    
                    if !viewModel.upcomingBookings.isEmpty {
                        BookingList(
                            title: "Upcoming Bookings",
                            bookings: viewModel.upcomingBookings
                        )
                    }
                    
                    if !viewModel.recentServices.isEmpty {
                        ServiceGrid(
                            title: "All Services",
                            services: viewModel.recentServices
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .navigationBarLeading
                ) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                }
                
                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }
            }
            .refreshable {
                await viewModel.fetchData()
            }
            .task {
                await viewModel.fetchData()
            }
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var popularServices: [CleaningService] = []
    @Published var recentServices: [CleaningService] = []
    @Published var upcomingBookings: [Booking] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchSubscription()
    }
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task {
                    await self?.searchServices(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func fetchData() async {
        isLoading = true
        defer { isLoading = false }
        
        async let popularTask = fetchPopularServices()
        async let recentTask = fetchRecentServices()
        async let bookingsTask = fetchUpcomingBookings()
        
        do {
            let (popular, recent, bookings) = try await (
                popularTask,
                recentTask,
                bookingsTask
            )
            
            popularServices = popular
            recentServices = recent
            upcomingBookings = bookings
        } catch {
            self.error = error
        }
    }
    
    private func fetchPopularServices() async throws -> [CleaningService] {
        let snapshot = try await db
            .collection("services")
            .whereField("isPopular", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: CleaningService.self)
        }
    }
    
    private func fetchRecentServices() async throws -> [CleaningService] {
        let snapshot = try await db
            .collection("services")
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: CleaningService.self)
        }
    }
    
    private func fetchUpcomingBookings() async throws -> [Booking] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db
            .collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: BookingStatus.upcoming.rawValue)
            .order(by: "date")
            .limit(to: 5)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Booking.self)
        }
    }
    
    private func searchServices(query: String) async {
        guard !query.isEmpty else {
            await fetchData()
            return
        }
        
        do {
            let snapshot = try await db
                .collection("services")
                .whereField("name", isGreaterThanOrEqualTo: query)
                .whereField("name", isLessThan: query + "z")
                .getDocuments()
            
            await MainActor.run {
                recentServices = snapshot.documents.compactMap { document in
                    try? document.data(as: CleaningService.self)
                }
            }
        } catch {
            self.error = error
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(
                placeholder,
                text: $text
            )
            .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
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

struct ServiceCarousel: View {
    let title: String
    let services: [CleaningService]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(services) { service in
                        PopularServiceCard(service: service)
                    }
                }
            }
        }
    }
}

struct ServiceGrid: View {
    let title: String
    let services: [CleaningService]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(services) { service in
                    ServiceCard(service: service)
                }
            }
        }
    }
}

struct BookingList: View {
    let title: String
    let bookings: [Booking]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(bookings) { booking in
                VStack(alignment: .leading, spacing: 10) {
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
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationService.shared)
}
