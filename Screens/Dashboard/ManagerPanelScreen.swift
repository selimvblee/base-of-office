import SwiftUI

/// Yönetici Paneli - Şirket Yöneticileri için Özel Panel
struct ManagerPanelScreen: View {
    @State private var selectedTab = 2 // "Raporlar" varsayılan
    @StateObject private var taskService = TaskService()
    
    let tabs = ["Üyeler", "Performans", "Raporlar", "Acil Durum"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header & Tabs
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Yönetici Paneli")
                                .font(AppTypography.title2(weight: AppTypography.bold))
                                .padding(.horizontal, 20)
                            
                            // Custom Tab Bar
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(0..<tabs.count, id: \.self) { index in
                                        managerTabItem(title: tabs[index], index: index)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Görev Durumu Sorma Bölümü
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "Görev Durumu", icon: "clipboard.fill")
                            
                            BrutalistButton(
                                title: "Ekibe Görev Durumunu Sor",
                                icon: "message.fill",
                                backgroundColor: .black
                            ) {
                                // Action
                            }
                            
                            // Durum Yanıtı Kartı
                            BrutalistCard(backgroundColor: AppColors.backgroundSecondary) {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(AppColors.textSecondary)
                                    Text("Henüz görev durumu yanıtı yok")
                                        .font(AppTypography.caption1())
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                }
                                .padding(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Temizlik Durumu Bölümü
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "Temizlik Durumu", icon: "sparkles")
                            
                            BrutalistButton(
                                title: "Ekibe Temizlik Durumunu Sor",
                                icon: "bubbles.and.sparkles.fill",
                                backgroundColor: AppColors.feedbackOrange
                            ) {
                                // Action
                            }
                            
                            // Temizlik Durumu Kartı (Ana Kart)
                            cleaningStatusSummaryCard
                            
                            // Takım Bilgisi
                            HStack {
                                Image(systemName: "circle.grid.3x3.fill")
                                Text("Takım: Base of Agency")
                                Spacer()
                            }
                            .font(AppTypography.caption1(weight: AppTypography.semiBold))
                            .padding(12)
                            .background(AppColors.backgroundSecondary)
                            .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
        }
    }
    
    // MARK: - Tab Item
    
    private func managerTabItem(title: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            VStack(spacing: 8) {
                Image(systemName: tabIcon(index: index))
                    .font(.title3)
                
                Text(title)
                    .font(AppTypography.caption1(weight: AppTypography.semiBold))
            }
            .foregroundColor(selectedTab == index ? AppColors.textPrimary : AppColors.textLight)
            .padding(.bottom, 8)
            .overlay(
                VStack {
                    Spacer()
                    if selectedTab == index {
                        Rectangle()
                            .fill(AppColors.textPrimary)
                            .frame(height: 3)
                    }
                }
            )
        }
    }
    
    private func tabIcon(index: Int) -> String {
        switch index {
        case 0: return "person.2.fill"
        case 1: return "chart.line.uptrend.xyaxis"
        case 2: return "doc.text.fill"
        case 3: return "exclamationmark.triangle.fill"
        default: return "circle"
        }
    }
    
    // MARK: - Components
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppColors.textSecondary)
            Text(title)
                .font(AppTypography.headline(weight: AppTypography.bold))
                .foregroundColor(AppColors.textPrimary)
        }
    }
    
    private var cleaningStatusSummaryCard: some View {
        // Örnek: Şu an temiz olduğunu varsayalım
        BrutalistCard(backgroundColor: AppColors.cleanGreen) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2.bold())
                    
                    VStack(alignment: .leading) {
                        Text("TÜM ALANLAR TEMİZ")
                            .font(AppTypography.headline(weight: AppTypography.bold))
                        Text("Bekleyen talep yok")
                            .font(AppTypography.caption2())
                    }
                    
                    Spacer()
                    
                    Text("TEMİZ")
                        .font(AppTypography.caption1(weight: AppTypography.black))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Ekibe Temizlik Durumunu Sor")
                    }
                    .font(AppTypography.caption1(weight: AppTypography.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.black)
                    .cornerRadius(8)
                }
            }
            .padding(16)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    ManagerPanelScreen()
}
