import SwiftUI

/// Ana Tab Görünümü - Alt Navigasyon Barı
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Screen Content
            Group {
                switch selectedTab {
                case 0:
                    HomeScreen()
                case 1:
                    CalendarPlaceholder() // Takvim ekranı için placeholder
                case 2:
                    ManagerPanelScreen()
                default:
                    HomeScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar (Neo-Brutalism)
            HStack(spacing: 0) {
                tabItem(index: 0, icon: "house.fill", title: "Home")
                tabItem(index: 1, icon: "calendar", title: "Calendar")
                tabItem(index: 2, icon: "person.circle.fill", title: "Yönetici")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.white)
            .overlay(
                Rectangle()
                    .frame(height: 3)
                    .foregroundColor(AppColors.border),
                alignment: .top
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func tabItem(index: Int, icon: String, title: String) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                
                Text(title)
                    .font(AppTypography.caption2(weight: selectedTab == index ? AppTypography.bold : AppTypography.medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selectedTab == index ? AppColors.taskRed : AppColors.textSecondary)
        }
    }
}

/// Takvim Ekranı Placeholder
struct CalendarPlaceholder: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "calendar")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.textLight)
                Text("Takvim Çok Yakında")
                    .font(AppTypography.title2(weight: AppTypography.bold))
            }
        }
    }
}

#Preview {
    MainTabView()
}
