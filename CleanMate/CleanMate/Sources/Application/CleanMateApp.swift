import SwiftUI
import Firebase
import FirebaseMessaging
import IQKeyboardManagerSwift

@main
struct CleanMateApp: App {
    @StateObject
    private var appState = AppState()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var delegate
    
    var body: some View {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        setupNotifications(application)
        setupKeyboardManager()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func setupNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        _ = UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { _, _ in }
        application.registerForRemoteNotifications()
    }
    
    private func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
