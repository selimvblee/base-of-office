import SwiftUI

/// Uygulama Navigasyon Yöneticisi
struct AppNavigator: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                if let user = authService.currentUser {
                    if user.teamId == nil {
                        // Takımı olmayan kullanıcılar
                        switch user.role {
                        case .company:
                            NavigationStack { CreateTeamScreen() }
                        case .employee, .partner:
                            NavigationStack { JoinTeamScreen() }
                        case .individual:
                            MainTabView()
                        }
                    } else {
                        // Takımı olan kullanıcılar
                        if user.role == .partner {
                            PartnerPanelScreen()
                        } else {
                            MainTabView()
                        }
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
