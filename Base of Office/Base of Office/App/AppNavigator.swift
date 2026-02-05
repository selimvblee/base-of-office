import SwiftUI

struct AppNavigator: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated && !authService.needsProfileSetup {
                // Tamamen giriş yapmış ve profili tamamlanmış kullanıcı
                HomeDashboardView()
            } else {
                // Giriş yapmamış veya profili eksik kullanıcı (Kurulum akışına girmesi gerekebilir)
                SignInScreen()
            }
        }
        .animation(.spring(), value: authService.isAuthenticated)
        .animation(.spring(), value: authService.needsProfileSetup)
    }
}
