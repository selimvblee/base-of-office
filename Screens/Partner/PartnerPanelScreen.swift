import SwiftUI

/// İş Ortağı Paneli - Dış hizmet sağlayıcılar için
struct PartnerPanelScreen: View {
    @StateObject private var authService = AuthService()
    @StateObject private var taskService = TaskService()
    
    @State private var serviceType = ""
    @State private var description = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("İş Ortağı Paneli")
                                .font(AppTypography.title2(weight: AppTypography.bold))
                            
                            Text("Şirketlere hizmet talebi gönderin ve onaylanan işlerinizi takip edin.")
                                .font(AppTypography.callout())
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Yeni Talep Formu
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Yeni Hizmet Talebi")
                                .font(AppTypography.headline(weight: AppTypography.bold))
                                .padding(.horizontal, 24)
                            
                            BrutalistCard(backgroundColor: .white) {
                                VStack(spacing: 16) {
                                    BrutalistTextField(
                                        placeholder: "Hizmet Türü (Örn: Teknik Destek)",
                                        icon: "briefcase.fill",
                                        text: $serviceType
                                    )
                                    
                                    BrutalistTextArea(
                                        placeholder: "Detaylı açıklama ve gereksinimler...",
                                        text: $description
                                    )
                                    
                                    BrutalistButton(
                                        title: "Talep Gönder",
                                        icon: "paperplane.fill",
                                        backgroundColor: AppColors.partnerPurple
                                    ) {
                                        sendRequest()
                                    }
                                }
                                .padding(20)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Aktif İşler / Talepler
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Talepleriniz")
                                .font(AppTypography.headline(weight: AppTypography.bold))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                // Örnek Talep Kartı
                                PartnerRequestItemCard(
                                    title: "Ofis Temizliği",
                                    status: "Bekliyor",
                                    date: "Bugün",
                                    color: AppColors.teamYellow
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
            .navigationTitle("Partner")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Başarılı", isPresented: $showSuccess) {
                Button("Tamam", role: .cancel) {
                    serviceType = ""
                    description = ""
                }
            } message: {
                Text("Hizmet talebiniz şirket yöneticisine iletildi.")
            }
        }
    }
    
    private func sendRequest() {
        guard !serviceType.isEmpty && !description.isEmpty else { return }
        // Firebase entegrasyonu buraya gelecek
        showSuccess = true
    }
}

struct PartnerRequestItemCard: View {
    let title: String
    let status: String
    let date: String
    let color: Color
    
    var body: some View {
        BrutalistCard(backgroundColor: .white) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.headline(weight: AppTypography.bold))
                    Text(date)
                        .font(AppTypography.caption2())
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text(status)
                    .font(AppTypography.caption1(weight: AppTypography.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(AppColors.border, lineWidth: 2))
                    .cornerRadius(4)
            }
            .padding(16)
        }
    }
}

#Preview {
    PartnerPanelScreen()
}
