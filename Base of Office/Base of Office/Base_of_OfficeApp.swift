import SwiftUI
import Firebase
import GoogleSignIn

@main
struct Base_of_OfficeApp: App {
    init() {
        FirebaseConfig.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppNavigator()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
