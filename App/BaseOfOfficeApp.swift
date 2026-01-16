import SwiftUI
import FirebaseCore

@main
struct BaseOfOfficeApp: App {
    // AppDelegate bağlantısı (Push Notification için gerekli)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Firebase başlatma
    init() {
        FirebaseConfig.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppNavigator()
                .environmentObject(NotificationService.shared)
        }
    }
}
