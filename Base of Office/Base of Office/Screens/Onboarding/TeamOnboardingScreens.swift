import SwiftUI

struct CreateTeamScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var teamService = TeamService.shared
    @State private var teamName = ""
    @State private var createdTeam: Team?
    @State private var showCodeModal = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Geri Butonu
                HStack {
                    BackButtonIcon()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Panelini Kur")
                        .font(.system(size: 28, weight: .black))
                    Text("Takımınız için bir isim belirleyin. Bu panelin kurucusu siz olacaksınız.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Takım / Şirket Adı")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    BrutalistTextField(
                        placeholder: "Örn: Ofis Panelim",
                        text: $teamName
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: {
                    handleCreate()
                }) {
                    if teamService.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        HStack {
                            Text("Paneli Oluştur")
                            Image(systemName: "checkmark.seal.fill")
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(teamName.isEmpty || teamService.isLoading)
                .brutalistButton(color: teamName.isEmpty ? AppColors.textTertiary : AppColors.primary)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
            
            if showCodeModal, let team = createdTeam {
                inviteCodeModal(team: team)
            }
        }
        .navigationBarBackButtonHidden(showCodeModal)
    }
    
    private func handleCreate() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        Task {
            let team = await teamService.createTeam(name: teamName, founderId: userId)
            if let team = team {
                await MainActor.run {
                    self.createdTeam = team
                    withAnimation { self.showCodeModal = true }
                }
            }
        }
    }
    
    private func inviteCodeModal(team: Team) -> some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Tebrikler! 🎉")
                        .font(.system(size: 24, weight: .black))
                    Text("Paneliniz kuruldu. Ekibinizi davet etmek için bu kodu kullanın:")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Text(team.inviteCode ?? "------")
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .kerning(4)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .brutalistCard(color: AppColors.backgroundSecondary)
                
                Button(action: { dismiss() }) {
                    Text("Dashboard'a Git")
                        .font(.system(size: 16, weight: .bold))
                }
                .buttonStyle(PlainButtonStyle())
                .brutalistButton(color: AppColors.primary)
            }
            .padding(32)
            .background(AppColors.background)
            .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
            .background(
                Rectangle()
                    .fill(Color.black)
                    .offset(x: 2, y: 2)
            )
            .padding(.trailing, 2)
            .padding(.bottom, 2)
            .padding(24)
        }
    }
}

struct JoinTeamScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var teamService = TeamService.shared
    @State private var code = ""
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Geri Butonu
                HStack {
                    BackButtonIcon()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Takıma Katıl")
                        .font(.system(size: 28, weight: .black))
                    Text("Kurucunuzdan aldığınız 6 haneli davet kodunu girin.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Davet Kodu")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    BrutalistTextField(
                        placeholder: "Örn: OFFICE",
                        text: $code,
                        keyboardType: .asciiCapable
                    )
                    .onChange(of: code) { newValue in
                         if newValue.count > 6 { code = String(newValue.prefix(6)) }
                    }
                }
                .padding(.horizontal, 24)
                
                if let error = teamService.errorMessage {
                    Text(error)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppColors.taskRed)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button(action: {
                    handleJoin()
                }) {
                    if teamService.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        HStack {
                            Text("Katıl")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(code.count < 6 && code != "OFFICE" || teamService.isLoading)
                .brutalistButton(color: code.isEmpty ? AppColors.textTertiary : AppColors.primary)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
    }
    
    private func handleJoin() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        Task {
            await teamService.joinTeam(code: code, userId: userId)
        }
    }
}
