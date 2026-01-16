import SwiftUI
import Combine

/// Yönetici Paneli - Şirket Yöneticileri için Özel Panel
struct ManagerPanelScreen: View {
    @Binding var selectedTab: Int
    @StateObject private var authService = AuthService.shared
    @StateObject private var taskService = TaskService.shared
    @State private var showAskStatusSheet = false
    @State private var showCleaningStatusSheet = false
    @State private var showActivityDetail = false
    @State private var selectedActivity: String?
    @State private var teamStatus: [TeamMemberStatus] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        quickStatsSection
                        askStatusSection
                        cleaningStatusSection
                        recentActivitySection
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .sheet(isPresented: $showAskStatusSheet) {
                AskTeamStatusSheet(teamStatus: $teamStatus)
            }
            .sheet(isPresented: $showCleaningStatusSheet) {
                CleaningReportSheet()
            }
        }
    }
    
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
            
            HStack(spacing: 12) {
                headerButton(icon: "house.fill") { selectedTab = 0 }
                headerButton(icon: "bell.fill", badgeCount: 2) {}
                
                Circle()
                    .fill(AppColors.taskRed)
                    .frame(width: 40, height: 40)
                    .overlay(Text(String(authService.currentUser?.username?.prefix(1) ?? authService.currentUser?.fullName?.prefix(1) ?? "Y")).font(.system(size: 16, weight: .bold)).foregroundColor(.white))
            }
        }
        .padding(.top, 10)
    }
    
    private func headerButton(icon: String, badgeCount: Int = 0, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(AppColors.backgroundSecondary)
                    .border(Color.black, width: 2)
                
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(AppColors.taskRed)
                        .border(Color.black, width: 1)
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı İstatistikler")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    statCard(title: "Ekip Üyeleri", value: "12", icon: "person.3.fill", backgroundColor: AppColors.taskRed)
                    statCard(title: "Aktif Görevler", value: "8", icon: "checklist", backgroundColor: AppColors.teamYellow)
                }
                
                HStack(spacing: 12) {
                    statCard(title: "Bekleyen Onay", value: "3", icon: "clock.fill", backgroundColor: AppColors.feedbackOrange)
                    statCard(title: "Performans", value: "85%", icon: "chart.line.uptrend.xyaxis", backgroundColor: AppColors.activityPurple)
                }
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, backgroundColor: Color) -> some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.2))
                    .border(Color.black, width: 1)
                
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
            .brutalistCard(color: backgroundColor, shadow: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Ask Status Section
    
    private var askStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "message.fill")
                    .foregroundColor(AppColors.textSecondary)
                Text("Görev Durumu")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
                Button(action: {
                    showAskStatusSheet = true
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Ekibe Göre Durumunu Sor")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .brutalistButton(color: AppColors.primary)
            
            // Team status responses
            if teamStatus.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(AppColors.textTertiary)
                    Text("Henüz görev durumu yanıtı yok")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.backgroundSecondary)
                .border(AppColors.border, width: 2)
            } else {
                ForEach(teamStatus) { status in
                    teamStatusCard(status: status)
                }
            }
        }
    }
    
    private func teamStatusCard(status: TeamMemberStatus) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(status.statusColor)
                .frame(width: 10, height: 10)
            
            Text(status.name)
                .font(.system(size: 14, weight: .semibold))
            
            Spacer()
            
            Text(status.status)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(12)
        .brutalistCard(color: AppColors.background, shadow: 3)
    }
    
    // MARK: - Cleaning Status Section
    
    private var cleaningStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.textSecondary)
                Text("Temizlik Durumu")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Button(action: {
                showCleaningStatusSheet = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TÜM ALANLAR TEMİZ")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Detayları görüntüle")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text("TEMİZ")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black)
                        .border(Color.white, width: 1)
                }
                .padding(16)
                .brutalistCard(color: AppColors.success)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Aktiviteler")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            activityCard(icon: "sparkles", title: "Temizlik Bildirimi", subtitle: "10:30", color: AppColors.activityPurple)
            activityCard(icon: "message.fill", title: "Takıma Geri Bildirim", subtitle: "09:15", color: AppColors.feedbackOrange)
        }
    }
    
    private func activityCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .border(Color.black, width: 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(14)
            .brutalistCard(color: color, shadow: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
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

// MARK: - Supporting Models

struct TeamMemberStatus: Identifiable {
    let id = UUID()
    let name: String
    let status: String
    let statusColor: Color
}

// MARK: - Supporting Sheets

struct AskTeamStatusSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var teamStatus: [TeamMemberStatus]
    @State private var isSending = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.activityPurple)
                
                Text("Görev Durumu Sor")
                    .font(.system(size: 22, weight: .bold))
                
                Text("Tüm ekip üyelerine görev durumu sorusu gönderilecek. Yanıtlar ana ekranda görünecek.")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: sendStatusRequest) {
                    HStack {
                        if isSending {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        Text(isSending ? "Gönderiliyor..." : "Ekibe Gönder")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .brutalistButton(color: isSending ? AppColors.textTertiary : AppColors.activityPurple)
                .disabled(isSending)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Durum Sorgula")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
    
    private func sendStatusRequest() {
        isSending = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.teamStatus = [
                TeamMemberStatus(name: "Ahmet Y.", status: "Görevde", statusColor: AppColors.success),
                TeamMemberStatus(name: "Mehmet K.", status: "Toplantıda", statusColor: AppColors.feedbackOrange),
                TeamMemberStatus(name: "Ayşe S.", status: "Görevde", statusColor: AppColors.success)
            ]
            
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            dismiss()
        }
    }
}

struct CleaningReportSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let cleaningAreas = [
        ("Ofis Alanı", true),
        ("Mutfak", true),
        ("Toplantı Odası", true),
        ("Tuvalet", true),
        ("Giriş Holü", true)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(cleaningAreas, id: \.0) { area, isClean in
                    HStack {
                        Image(systemName: isClean ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isClean ? AppColors.success : AppColors.taskRed)
                        
                        Text(area)
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        Text(isClean ? "Temiz" : "Temizlenmeli")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(14)
                    .background(AppColors.backgroundSecondary)
                    .border(AppColors.border, width: 2)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Temizlik Durumu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ManagerPanelScreen(selectedTab: .constant(0))
}
