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
                        // Header: Tarih ve Kullanıcı Karşılama
                        headerSection
                            .padding(.top, 10)
                        
                        // Öne Çıkan Şirket/Takım Kartı
                        featuredTeamCard
                        
                        // Quick Stats (Izgara Düzeni)
                        quickStatsSection
                        
                        // Recent Activity (Son Aktiviteler)
                        recentActivitySection
                        
                        Spacer()
                            .frame(height: 100) // Tab bar için boşluk
                    }
                    .padding(.horizontal, 20)
                }
                
                // Floating Action Button (+)
                floatingActionButton
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(currentDateTurkish)
                    .font(AppTypography.headline(weight: AppTypography.bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(currentFullDateTurkish)
                    .font(AppTypography.caption1())
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Merhaba, \(authService.currentUser?.fullName.split(separator: " ").first ?? "Kullanıcı") 👋")
                    .font(AppTypography.title2(weight: AppTypography.bold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 8)
            }
            
            Spacer()
            
            // Üst Sağ Butonlar
            HStack(spacing: 12) {
                topIconButton(icon: "house.fill")
                topIconButton(icon: "bell.fill")
                topIconButton(icon: "rectangle.portrait.and.arrow.right") {
                    try? authService.signOut()
                }
                
                // Profil Avatarı
                Circle()
                    .fill(AppColors.taskRed)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(authService.currentUser?.fullName.prefix(1) ?? "U")
                            .font(AppTypography.headline(weight: AppTypography.bold))
                            .foregroundColor(.white)
                    )
                    .overlay(Circle().stroke(AppColors.border, lineWidth: 2))
            }
        }
    }
    
    private func topIconButton(icon: String, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
            Image(systemName: icon)
                .font(AppTypography.headline(weight: AppTypography.bold))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 40, height: 40)
                .background(.white)
                .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                .mediumBrutalistShadow()
        }
    }
    
    // MARK: - Featured Team Card
    
    private var featuredTeamCard: some View {
        BrutalistCard(backgroundColor: AppColors.taskRed) {
            HStack(spacing: 16) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.companyBlue)
                    .frame(width: 60, height: 60)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.border, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Base of Agency") // Örnek veri, gerçekte takımdan gelecek
                        .font(AppTypography.headline(weight: AppTypography.bold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "folder.fill")
                        Text("Departman:")
                    }
                    .font(AppTypography.caption2())
                    .foregroundColor(.white.opacity(0.9))
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "person.2.fill")
                            Text("Ekibi görüntüle")
                        }
                        .font(AppTypography.caption2(weight: AppTypography.semiBold))
                        .foregroundColor(AppColors.teamYellow)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.teamYellow)
            }
            .padding(16)
        }
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(AppTypography.title3(weight: AppTypography.bold))
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                QuickStatsCard(
                    title: "Görevlerim",
                    value: "0",
                    icon: "checkmark.circle.fill",
                    backgroundColor: AppColors.taskRed,
                    size: .medium
                )
                
                QuickStatsCard(
                    title: "Takım Görevleri",
                    value: "0",
                    icon: "person.2.fill",
                    backgroundColor: AppColors.teamYellow,
                    size: .medium
                )
                
                QuickStatsCard(
                    title: "Yaklaşan Eylemler",
                    value: "0",
                    icon: "calendar.badge.clock",
                    backgroundColor: AppColors.feedbackOrange,
                    size: .medium
                )
                
                QuickStatsCard(
                    title: "Verimlilik",
                    value: "%0",
                    icon: "chart.line.uptrend.xyaxis",
                    backgroundColor: AppColors.activityPurple,
                    size: .medium
                )
            }
        }
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(AppTypography.title3(weight: AppTypography.bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                // Temizlik Bildirimi Kartı
                ActivityCard(
                    title: "Temizlik Bildirimi",
                    description: "Ofis temizlik durumunu bildir",
                    time: "",
                    icon: "paintpalette.fill",
                    iconColor: AppColors.activityPurple
                )
                
                // Geri Bildirim Kartı
                ActivityCard(
                    title: "Takıma Geri Bildirim",
                    description: "Takımınıza mesaj gönderin",
                    time: "",
                    icon: "bubble.left.fill",
                    iconColor: AppColors.feedbackOrange
                )
            }
        }
    }
    
    // MARK: - Floating Action Button
    
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(AppColors.taskRed)
                        .overlay(Circle().stroke(AppColors.border, lineWidth: 3))
                        .mediumBrutalistShadow()
                }
                .padding(.trailing, 24)
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var currentDateTurkish: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).capitalized
    }
    
    private var currentFullDateTurkish: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date())
    }
}

#Preview {
    HomeScreen()
}
