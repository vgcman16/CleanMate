# CleanMate - iOS Cleaning Service App

CleanMate is a modern iOS application that connects users with professional cleaning services. Built with SwiftUI, it provides a seamless booking experience with real-time availability, secure payments, and service tracking.

## Features

- 🏠 Browse and book cleaning services
- 👥 View top-rated cleaners
- 📅 Manage upcoming and past bookings
- 💬 In-app messaging with service providers
- 💳 Secure payment processing
- 👤 User profile management

## Technical Stack

- iOS 18.1+
- SwiftUI
- Firebase (Authentication, Firestore, Storage, Messaging)
- Stripe Payment Gateway
- SDWebImage for image caching
- IQKeyboardManager for keyboard handling

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 18.1+
- CocoaPods

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/CleanMate.git
```

2. Install dependencies
```bash
cd CleanMate
pod install
```

3. Open the workspace
```bash
open CleanMate.xcworkspace
```

4. Add your configuration files:
- Add `GoogleService-Info.plist` for Firebase
- Configure Stripe API keys in the environment

## Architecture

The app follows a clean architecture pattern with:
- SwiftUI Views for the UI layer
- MVVM pattern for view logic
- Repository pattern for data access
- Service layer for business logic

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
