import SwiftUI

/// Ana Dashboard (Şirket Paneli) - Neo-Brutalism Tasarım
struct HomeScreen: View {
    @StateObject private var authService = AuthService()
    @StateObject private var taskService = TaskService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                            .padding(.top, 10)
                        
                        // Öne Çıkan Takım Kartı
                        featuredTeamCard
                        
                        // Takım Sohbeti
                        teamChatSection
                        
                        // Quick Stats
                        quickStatsSection
                        
                        // Recent Activity
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
        HStack(alignment: .top) {
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
                headerButton(icon: "rectangle.portrait.and.arrow.right") {
                    try? authService.signOut()
                }
                
                // Profile Avatar
                Circle()
                    .fill(AppColors.taskRed)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(authService.currentUser?.fullName.prefix(1) ?? "U")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .overlay(Circle().stroke(AppColors.border, lineWidth: 2))
            }
        }
    }
    
    private func headerButton(icon: String, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
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
    
    // MARK: - Featured Team Card
    
    private var featuredTeamCard: some View {
        HStack(spacing: 16) {
            // Team Icon
            Image(systemName: "building.2.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.companyBlue)
                .frame(width: 60, height: 60)
                .background(.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.border, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Base of Agency")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 11))
                    Text("Departman:")
                        .font(.system(size: 11))
                }
                .foregroundColor(.white.opacity(0.9))
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                    Text("Ekibi görüntüle")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(AppColors.teamYellow)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.teamYellow)
                .frame(width: 36, height: 36)
                .background(AppColors.teamYellow.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(16)
        .background(AppColors.taskRed)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 3)
        )
        .shadow(color: AppColors.border, radius: 0, x: 4, y: 4)
    }
    
    // MARK: - Team Chat Section
    
    private var teamChatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bubble.left.fill")
                    .foregroundColor(AppColors.textSecondary)
                Text("Takım Sohbeti")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 12) {
                // Empty state
                VStack(spacing: 8) {
                    Text("Henüz mesaj yok.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    Text("İlk mesajı siz gönderin! 💬")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textLight)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Mesaj yazın...", text: .constant(""))
                        .font(.system(size: 14))
                        .padding(12)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.border, lineWidth: 2)
                        )
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.feedbackOrange)
                    }
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
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // 2x2 Grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Görevlerim - Kırmızı
                    statCard(
                        title: "Görevlerim",
                        value: "0",
                        icon: "checkmark.circle.fill",
                        backgroundColor: AppColors.taskRed
                    )
                    
                    // Takım Görevleri - Sarı
                    statCard(
                        title: "Takım Görevleri",
                        value: "0",
                        icon: "person.2.fill",
                        backgroundColor: AppColors.teamYellow
                    )
                }
                
                HStack(spacing: 12) {
                    // Yaklaşan Eylemler - Turuncu
                    statCard(
                        title: "Yaklaşan Eylemler",
                        value: "0",
                        icon: "calendar.badge.clock",
                        backgroundColor: AppColors.feedbackOrange
                    )
                    
                    // Verimlilik - Mor
                    statCard(
                        title: "Verimlilik",
                        value: "%0",
                        icon: "chart.line.uptrend.xyaxis",
                        backgroundColor: AppColors.activityPurple
                    )
                }
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon with semi-transparent background
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
            
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
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
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
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            
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
    HomeScreen()
}
