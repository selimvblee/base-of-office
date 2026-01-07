import SwiftUI

/// Takım Oluşturma Ekranı - Onboarding
struct CreateTeamScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var teamService = TeamService()
    @StateObject private var authService = AuthService()
    
    @State private var teamName = ""
    @State private var myRole = ""
    @State private var occupations: [String] = []
    @State private var departments: [String] = []
    
    @State private var showInviteModal = false
    @State private var createdTeam: Team?
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Başlık
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Yeni Takım")
                            .font(AppTypography.title1(weight: AppTypography.bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Şirketiniz için bir takım oluşturun ve ekip üyelerinizi davet edin.")
                            .font(AppTypography.callout())
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 24) {
                        // Takım Adı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Takım Adı")
                                .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                .foregroundColor(AppColors.textSecondary)
                            
                            BrutalistTextField(
                                placeholder: "Örn: Base of Agency",
                                icon: "building.2.fill",
                                text: $teamName
                            )
                        }
                        
                        // Kullanıcı Rolü
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sizin Rolünüz / Ünvanınız")
                                .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                .foregroundColor(AppColors.textSecondary)
                            
                            BrutalistTextField(
                                placeholder: "Örn: Kurucu, Yönetici",
                                icon: "person.fill",
                                text: $myRole
                            )
                        }
                        
                        // Meslekler (Tag Input)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ekipteki Meslekler")
                                .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                .foregroundColor(AppColors.textSecondary)
                            
                            BrutalistTagInput(
                                placeholder: "Meslek ekle (Örn: Tasarımcı)",
                                tags: $occupations
                            )
                        }
                        
                        // Departmanlar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Departmanlar")
                                .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                .foregroundColor(AppColors.textSecondary)
                            
                            BrutalistTagInput(
                                placeholder: "Departman ekle (Örn: A Blok)",
                                tags: $departments
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Oluştur Butonu
                    BrutalistButton.task(title: "Takım Oluştur", icon: nil) {
                        handleCreateTeam()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            // Invite Modal
            if showInviteModal, let team = createdTeam {
                InviteCodeModal(team: team) {
                    showInviteModal = false
                    // Navigasyon buraya gelecek (Dashboard'a)
                }
            }
            
            // Loading Overlay
            if teamService.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleCreateTeam() {
        guard !teamName.isEmpty, let userId = authService.currentUser?.id else { return }
        
        Task {
            do {
                let team = try await teamService.createTeam(
                    name: teamName,
                    description: myRole, // Ünvanı açıklama olarak kullanıyoruz
                    founderId: userId,
                    occupations: occupations
                )
                
                await MainActor.run {
                    self.createdTeam = team
                    self.showInviteModal = true
                }
            } catch {
                print("❌ Takım oluşturma hatası: \(error.localizedDescription)")
            }
        }
    }
}

/// Davet Kodu Modalı - Neo-Brutalism
struct InviteCodeModal: View {
    let team: Team
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Takım Oluşturuldu! 🥳")
                        .font(AppTypography.title2(weight: AppTypography.bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Takımınız başarıyla oluşturuldu. Davet Kodunuz:")
                        .font(AppTypography.callout())
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Davet Kodu Kutusu
                Text(team.inviteCode)
                    .font(AppTypography.largeTitle(weight: AppTypography.black))
                    .kerning(4)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .background(AppColors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 3)
                    )
                    .cornerRadius(12)
                
                Text("Bu kodu ekip üyelerinizle paylaşın.")
                    .font(AppTypography.caption1())
                    .foregroundColor(AppColors.textLight)
                
                BrutalistButton.task(title: "Dashboard'a Git", icon: nil) {
                    onDismiss()
                }
            }
            .padding(32)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border, lineWidth: 4)
            )
            .cornerRadius(16)
            .largeBrutalistShadow()
            .padding(24)
        }
    }
}

#Preview {
    CreateTeamScreen()
}
