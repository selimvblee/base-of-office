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
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Quick Stats
                        quickStatsRow
                        
                        // Yeni Talep Formu
                        newRequestSection
                        
                        // Talepleriniz
                        requestsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
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
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("İş Ortağı Paneli")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Şirketlere hizmet talebi gönderin")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Profile Avatar
            Circle()
                .fill(AppColors.partnerPurple)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(authService.currentUser?.fullName.prefix(1) ?? "P")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
                .overlay(Circle().stroke(AppColors.border, lineWidth: 2))
        }
        .padding(.top, 16)
    }
    
    // MARK: - Quick Stats Row
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Bekleyen Talepler
            miniStatCard(
                title: "Bekleyen",
                value: "2",
                icon: "clock.fill",
                color: AppColors.teamYellow
            )
            
            // Onaylanan
            miniStatCard(
                title: "Onaylanan",
                value: "5",
                icon: "checkmark.circle.fill",
                color: AppColors.successGreen
            )
            
            // Reddedilen
            miniStatCard(
                title: "Reddedilen",
                value: "1",
                icon: "xmark.circle.fill",
                color: AppColors.taskRed
            )
        }
    }
    
    private func miniStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 3)
        )
        .shadow(color: AppColors.border, radius: 0, x: 3, y: 3)
    }
    
    // MARK: - New Request Section
    
    private var newRequestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppColors.partnerPurple)
                Text("Yeni Hizmet Talebi")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 14) {
                // Service Type Input
                TextField("Hizmet Türü (Örn: Teknik Destek)", text: $serviceType)
                    .font(.system(size: 14))
                    .padding(14)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.border, lineWidth: 2)
                    )
                
                // Description Input
                TextField("Detaylı açıklama...", text: $description, axis: .vertical)
                    .font(.system(size: 14))
                    .lineLimit(4...6)
                    .padding(14)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.border, lineWidth: 2)
                    )
                
                // Submit Button
                Button(action: sendRequest) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Talep Gönder")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.partnerPurple)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 3)
                    )
                    .shadow(color: AppColors.border, radius: 0, x: 4, y: 4)
                }
            }
            .padding(16)
            .background(AppColors.background)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 3)
            )
            .shadow(color: AppColors.border, radius: 0, x: 4, y: 4)
        }
    }
    
    // MARK: - Requests Section
    
    private var requestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.clipboard.fill")
                    .foregroundColor(AppColors.activityPurple)
                Text("Talepleriniz")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 12) {
                // Pending Request
                requestCard(
                    title: "Ofis Temizliği",
                    date: "Bugün, 10:30",
                    status: "Bekliyor",
                    statusColor: AppColors.teamYellow
                )
                
                // Approved Request
                requestCard(
                    title: "Teknik Destek",
                    date: "Dün, 14:00",
                    status: "Onaylandı",
                    statusColor: AppColors.successGreen
                )
                
                // Rejected Request
                requestCard(
                    title: "Güvenlik Kontrolü",
                    date: "2 gün önce",
                    status: "Reddedildi",
                    statusColor: AppColors.taskRed
                )
            }
        }
    }
    
    private func requestCard(title: String, date: String, status: String, statusColor: Color) -> some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: "briefcase.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(AppColors.partnerPurple)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Status Badge
            Text(status)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppColors.border, lineWidth: 2)
                )
        }
        .padding(14)
        .background(AppColors.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 2)
        )
        .shadow(color: AppColors.border, radius: 0, x: 3, y: 3)
    }
    
    // MARK: - Actions
    
    private func sendRequest() {
        guard !serviceType.isEmpty && !description.isEmpty else { return }
        showSuccess = true
    }
}

#Preview {
    PartnerPanelScreen()
}
