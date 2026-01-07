import SwiftUI

/// Takıma Katılma Ekranı - Onboarding (Çalışanlar ve Partnerler için)
struct JoinTeamScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var teamService = TeamService()
    @StateObject private var authService = AuthService()
    
    @State private var inviteCode = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Başlık
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.teamYellow)
                        .padding(.top, 40)
                    
                    Text("Takıma Katıl")
                        .font(AppTypography.title1(weight: AppTypography.bold))
                    
                    Text("Size iletilen 6 haneli davet kodunu aşağıya girerek ekibinize katılın.")
                        .font(AppTypography.callout())
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Kod Girişi
                VStack(spacing: 16) {
                    BrutalistTextField(
                        placeholder: "Davet Kodu (Örn: BAW4H3)",
                        icon: "key.fill",
                        text: $inviteCode
                    )
                    .textCase(.uppercase)
                }
                .padding(.horizontal, 24)
                
                // Katıl Butonu
                BrutalistButton.team(title: "Takıma Katıl", icon: "arrow.right.circle.fill") {
                    handleJoinTeam()
                }
                .padding(.horizontal, 24)
                
                // Geri / Çıkış
                Button(action: { try? authService.signOut() }) {
                    Text("Çıkış Yap")
                        .font(AppTypography.caption1(weight: AppTypography.bold))
                        .foregroundColor(AppColors.textLight)
                }
                
                Spacer()
            }
            
            // Loading Overlay
            if teamService.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(teamService.errorMessage ?? "Geçersiz kod.")
        }
    }
    
    private func handleJoinTeam() {
        guard inviteCode.count == 6, let userId = authService.currentUser?.id else {
            showError = true
            return
        }
        
        Task {
            do {
                try await teamService.joinTeamWithCode(inviteCode: inviteCode, userId: userId)
                // AppNavigator otomatik olarak ana ekrana geçecek
            } catch {
                await MainActor.run {
                    showError = true
                }
            }
        }
    }
}

#Preview {
    JoinTeamScreen()
}
