import SwiftUI

/// Yönetici Paneli - Şirket Yöneticileri için Özel Panel
struct ManagerPanelScreen: View {
    @StateObject private var taskService = TaskService()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Hızlı İstatistikler (Quick Stats)
                        quickStatsSection
                        
                        // Temizlik Durumu
                        cleaningStatusSection
                        
                        // Son Aktiviteler
                        recentActivitySection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(currentDayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(currentDateString)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Header Buttons
            HStack(spacing: 12) {
                headerButton(icon: "house.fill")
                headerButton(icon: "bell.fill")
                headerButton(icon: "rectangle.portrait.and.arrow.right")
                
                // Profile Avatar
                Circle()
                    .fill(AppColors.taskRed)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("D")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.top, 10)
    }
    
    private func headerButton(icon: String) -> some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 40, height: 40)
                .background(AppColors.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.border, lineWidth: 2)
                )
        }
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı İstatistikler")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // 2x2 Grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Ekip Üyeleri - Kırmızı
                    statCard(
                        title: "Ekip Üyeleri",
                        value: "12",
                        icon: "person.3.fill",
                        backgroundColor: AppColors.taskRed
                    )
                    
                    // Aktif Görevler - Sarı
                    statCard(
                        title: "Aktif Görevler",
                        value: "8",
                        icon: "checklist",
                        backgroundColor: AppColors.teamYellow
                    )
                }
                
                HStack(spacing: 12) {
                    // Bekleyen Onay - Turuncu
                    statCard(
                        title: "Bekleyen Onay",
                        value: "3",
                        icon: "clock.fill",
                        backgroundColor: AppColors.feedbackOrange
                    )
                    
                    // Performans - Mor
                    statCard(
                        title: "Performans",
                        value: "85%",
                        icon: "chart.line.uptrend.xyaxis",
                        backgroundColor: AppColors.activityPurple
                    )
                }
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon in top-left
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
            
            // Title
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 3)
        )
        .shadow(color: AppColors.border, radius: 0, x: 4, y: 4)
    }
    
    // MARK: - Cleaning Status Section
    
    private var cleaningStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Temizlik Durumu")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // Green status card
            HStack {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("TÜM ALANLAR TEMİZ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Badge
                Text("TEMİZ")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black)
                    .cornerRadius(4)
            }
            .padding(16)
            .background(AppColors.successGreen)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 3)
            )
            .shadow(color: AppColors.border, radius: 0, x: 4, y: 4)
        }
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Aktiviteler")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // Temizlik Bildirimi - Purple
            activityCard(
                icon: "sparkles",
                title: "Temizlik Bildirimi",
                subtitle: "Ofis temizlik durumunu bildir",
                color: AppColors.activityPurple,
                showArrow: true
            )
            
            // Takıma Geri Bildirim - Orange
            activityCard(
                icon: "message.fill",
                title: "Takıma Geri Bildirim",
                subtitle: "Takımınıza mesaj gönderin",
                color: AppColors.feedbackOrange,
                showPlusButton: true
            )
        }
    }
    
    private func activityCard(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        showArrow: Bool = false,
        showPlusButton: Bool = false
    ) -> some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if showPlusButton {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(AppColors.taskRed)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.border, lineWidth: 2)
                        )
                }
            }
        }
        .padding(14)
        .background(color)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 3)
        )
        .shadow(color: AppColors.border, radius: 0, x: 4, y: 4)
    }
    
    // MARK: - Helpers
    
    private var currentDayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).capitalized
    }
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date())
    }
}

#Preview {
    ManagerPanelScreen()
        .environmentObject(AuthService())
}
