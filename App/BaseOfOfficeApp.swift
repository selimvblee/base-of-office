import SwiftUI
import FirebaseCore

@main
struct BaseOfOfficeApp: App {
    // Firebase başlatma
    init() {
        // FirebaseConfig.shared.configure() // Mevcut bir GoogleService-Info.plist gerektiği için şimdilik kapalı
    }
    
    var body: some Scene {
        WindowGroup {
            AppNavigator()
        }
    }
}
