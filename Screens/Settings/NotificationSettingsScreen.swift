import SwiftUI

/// Bildirim Ayarları Ekranı - Neo-Brutalist Tasarım
struct NotificationSettingsScreen: View {
    @EnvironmentObject var notificationService: NotificationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var taskNotifications = true
    @State private var teamNotifications = true
    @State private var cleaningAlerts = true
    @State private var partnerNotifications = true
    @State private var dueDateReminders = true
    @State private var isRequestingPermission = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Permission Status Card
                        permissionCard
                        
                        // Notification Categories
                        if notificationService.isPermissionGranted {
                            notificationCategories
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Permission Card
    
    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: notificationService.isPermissionGranted ? "bell.badge.fill" : "bell.slash.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(notificationService.isPermissionGranted ? AppColors.successGreen : AppColors.taskRed)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Push Bildirimleri")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(notificationService.isPermissionGranted ? "Aktif" : "Devre Dışı")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(notificationService.isPermissionGranted ? AppColors.successGreen : AppColors.textSecondary)
                }
                
                Spacer()
                
                if !notificationService.isPermissionGranted {
                    Button(action: requestPermission) {
                        if isRequestingPermission {
                            ProgressView()
                                .tint(AppColors.background)
                        } else {
                            Text("Etkinleştir")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(AppColors.background)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.activityPurple)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.border, lineWidth: 3)
                    )
                    .shadow(color: AppColors.border, radius: 0, x: 4, y: 4)
                }
            }
            
            if !notificationService.isPermissionGranted {
                Text("Görevler, takım güncellemeleri ve temizlik uyarıları hakkında bildirim almak için izin verin.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(20)
        .background(AppColors.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 3)
        )
        .shadow(color: AppColors.border, radius: 0, x: 5, y: 5)
    }
    
    // MARK: - Notification Categories
    
    private var notificationCategories: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Bildirim Kategorileri")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            
            // Task Notifications
            notificationToggle(
                icon: "list.bullet.circle.fill",
                title: "Görev Bildirimleri",
                subtitle: "Yeni görev atamaları ve tamamlananlar",
                color: AppColors.taskRed,
                isOn: $taskNotifications
            )
            
            // Team Notifications
            notificationToggle(
                icon: "person.3.fill",
                title: "Takım Bildirimleri",
                subtitle: "Takım davetleri ve güncellemeler",
                color: AppColors.teamYellow,
                isOn: $teamNotifications
            )
            
            // Due Date Reminders
            notificationToggle(
                icon: "clock.fill",
                title: "Tarih Hatırlatıcıları",
                subtitle: "Yaklaşan görev son tarihleri",
                color: AppColors.feedbackOrange,
                isOn: $dueDateReminders
            )
            
            // Cleaning Alerts
            notificationToggle(
                icon: "sparkles",
                title: "Temizlik Uyarıları",
                subtitle: "Temizlik durumu bildirimleri",
                color: AppColors.activityPurple,
                isOn: $cleaningAlerts
            )
            
            // Partner Notifications
            notificationToggle(
                icon: "person.crop.circle.badge.checkmark",
                title: "İş Ortağı Bildirimleri",
                subtitle: "İş ortağı talep ve onayları",
                color: AppColors.partnerPurple,
                isOn: $partnerNotifications
            )
        }
        .padding(20)
        .background(AppColors.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 3)
        )
        .shadow(color: AppColors.border, radius: 0, x: 5, y: 5)
    }
    
    // MARK: - Toggle Component
    
    private func notificationToggle(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.border, lineWidth: 2)
                )
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(14)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColors.border, lineWidth: 2)
        )
    }
    
    // MARK: - Actions
    
    private func requestPermission() {
        isRequestingPermission = true
        Task {
            _ = await notificationService.requestPermission()
            await MainActor.run {
                isRequestingPermission = false
            }
        }
    }
}

#Preview {
    NotificationSettingsScreen()
        .environmentObject(NotificationService.shared)
}
