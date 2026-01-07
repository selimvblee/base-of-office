import SwiftUI

/// Uygulama Navigasyon Yöneticisi
struct AppNavigator: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                if let user = authService.currentUser {
                    if user.teamId == nil && user.role == .company {
                        // Şirket yöneticisi ve henüz takım kurmamış
                        NavigationStack {
                            CreateTeamScreen()
                        }
                    } else if user.role == .partner {
                        // İş ortağı için özel dashboard
                        PartnerPanelScreen()
                    } else {
                        // Ana uygulama
                        MainTabView()
                    }
                } else {
                    // Kullanıcı verisi yükleniyor
                    ZStack {
                        AppColors.background.ignoresSafeArea()
                        ProgressView()
                    }
                }
            } else {
                // Giriş yapmamış
                SignInScreen()
            }
        }
        .animation(.default, value: authService.isAuthenticated)
    }
}

#Preview {
    AppNavigator()
}
