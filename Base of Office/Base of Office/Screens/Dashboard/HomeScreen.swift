import SwiftUI
import Combine

/// Ana Dashboard (Şirket Paneli) - Neo-Brutalism Tasarım
struct HomeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @StateObject private var taskService = TaskService.shared
    @StateObject private var teamService = TeamService.shared
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var showNotifications = false
    @State private var showLogoutAlert = false
    @State private var showTeamDetail = false
    @State private var showMyTasks = false
    @State private var showTeamTasks = false
    @State private var showUpcoming = false
    @State private var showPerformance = false
    @State private var showCleaningReport = false
    @State private var showFeedback = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                            .padding(.top, 10)
                        
                        featuredTeamCard
                        teamChatSection
                        quickStatsSection
                        recentActivitySection
                        
                        // Takım Yönetimi (Sadece Kurucu Görür)
                        if authService.currentUser?.role == .founder {
                            teamManagementSection
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .sheet(isPresented: $showNotifications) { NotificationsSheet() }
            .sheet(isPresented: $showTeamDetail) { TeamDetailSheet() }
            .sheet(isPresented: $showMyTasks) { MyTasksSheet(tasks: taskService.myTasks) }
            .sheet(isPresented: $showTeamTasks) { TeamTasksSheet() }
            .sheet(isPresented: $showUpcoming) { UpcomingSheet() }
            .sheet(isPresented: $showPerformance) { PerformanceSheet() }
            .sheet(isPresented: $showCleaningReport) { CleaningReportSheetHome() }
            .sheet(isPresented: $showFeedback) { FeedbackSheet() }
            .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
                Button("İptal", role: .cancel) { }
                Button("Çıkış", role: .destructive) {
                    AuthService.shared.signOut()
                }
            } message: {
                Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?")
            }
        }
    }
    
    // MARK: - Team Management (Founder Only)
    
    private var teamManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ekip ve Yetkiler")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Ekip üyelerinin yetkilerini buradan yönetin.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                
                // Davet Kodu Göstergesi
                if let team = TeamService.shared.currentTeam {
                    Text(team.inviteCode ?? "---")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.teamYellow.opacity(0.2))
                        .overlay(Rectangle().stroke(AppColors.teamYellow, lineWidth: 2))
                }
            }
            
            VStack(spacing: 12) {
                // Demo Üyeler
                memberRow(name: "Siz (Kurucu)", role: .founder, isMe: true)
                memberRow(name: "Ahmet Yılmaz", role: .manager, isMe: false)
                memberRow(name: "Mehmet Demir", role: .user, isMe: false)
                memberRow(name: "Ayşe Kaya", role: .user, isMe: false)
            }
        }
        .padding(16)
        .brutalistCard()
    }
    
    private func memberRow(name: String, role: UserRole, isMe: Bool) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isMe ? AppColors.taskRed : AppColors.activityPurple)
                .frame(width: 36, height: 36)
                .overlay(Text(name.prefix(1)).font(.system(size: 14, weight: .bold)).foregroundColor(.white))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 14, weight: .semibold))
                Text(role.displayName).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            if !isMe {
                Menu {
                    Button(action: { /* Rolü Yönetici yap */ }) {
                        Label("Yönetici Yap", systemImage: "shield.fill")
                    }
                    Button(action: { /* Rolü Kullanıcı yap */ }) {
                        Label("Kullanıcı Yap", systemImage: "person.fill")
                    }
                    Button(role: .destructive, action: { /* Takımdan çıkar */ }) {
                        Label("Takımdan Çıkar", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(4)
                }
            }
        }
        .padding(10)
        .brutalistCard(color: AppColors.background.opacity(0.8), shadow: 3)
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
            
            HStack(spacing: 12) {
                headerButton(icon: "house.fill") {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                }
                
                headerButton(icon: "bell.fill", badgeCount: 3) {
                    showNotifications = true
                }
                
                headerButton(icon: "rectangle.portrait.and.arrow.right") {
                    showLogoutAlert = true
                }
                
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 44, height: 44)
                    .overlay(Text(String(authService.currentUser?.username?.prefix(1) ?? authService.currentUser?.fullName?.prefix(1) ?? "U")).font(.system(size: 18, weight: .black)).foregroundColor(.white))
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .background(
                        Circle()
                            .fill(Color.black)
                            .offset(x: 2, y: 2)
                    )
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
            }
        }
    }
    
    private func headerButton(icon: String, badgeCount: Int = 0, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.background)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                    .background(
                        Rectangle()
                            .fill(Color.black)
                            .offset(x: 2, y: 2)
                    )
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
                
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
            }
        }
        .padding(.trailing, 3) 
    }
    
    // MARK: - Featured Team Card
    
    private var featuredTeamCard: some View {
        Button(action: { showTeamDetail = true }) {
            HStack(spacing: 16) {
                // Sol taraftaki ikon container
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.companyBlue)
                }
                .frame(width: 56, height: 56)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamService.currentTeam?.name ?? "Panelim")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill").font(.system(size: 10))
                            Text("Departman: Yazılım").font(.system(size: 10))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill").font(.system(size: 10))
                            Text("12 Ekip Üyesi").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(AppColors.teamYellow)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.square.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.teamYellow)
                    .background(
                        Rectangle()
                            .fill(Color.black)
                            .offset(x: 2, y: 2)
                    )
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
            }
            .padding(16)
            .brutalistCard(color: AppColors.taskRed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Team Chat Section
    
    private var teamChatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bubble.left.fill").foregroundColor(AppColors.textSecondary)
                Text("Takım Sohbeti").font(.system(size: 16, weight: .bold)).foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 12) {
                if messages.isEmpty {
                    VStack(spacing: 8) {
                        Text("Henüz mesaj yok.").font(.system(size: 14)).foregroundColor(AppColors.textSecondary)
                        Text("İlk mesajı siz gönderin! 💬").font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(messages) { message in
                                chatBubble(message: message)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 250)
                }
                
                HStack(spacing: 12) {
                    TextField("Mesaj yazın...", text: $messageText)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(AppColors.background)
                        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                        .onSubmit { sendMessage() }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? AppColors.textTertiary : AppColors.primary)
                    }
                    .disabled(messageText.isEmpty)
                }
            }
            .padding(16)
            .brutalistCard()
        }
    }
    
    private func chatBubble(message: ChatMessage) -> some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(message.isFromCurrentUser ? .white : AppColors.textPrimary)
                    .padding(12)
                    .background(message.isFromCurrentUser ? AppColors.warning : AppColors.background)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                Text(message.timeString).font(.system(size: 10)).foregroundColor(AppColors.textTertiary)
            }
            if !message.isFromCurrentUser { Spacer() }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newMessage = ChatMessage(id: UUID().uuidString, text: messageText.trimmingCharacters(in: .whitespaces), isFromCurrentUser: true, timestamp: Date())
        withAnimation(.easeInOut(duration: 0.2)) { messages.append(newMessage) }
        messageText = ""
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı İstatistikler").font(.system(size: 20, weight: .black)).foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    statCard(title: "Görevlerim", value: "\(taskService.myTasks.count)", icon: "checkmark.circle.fill", backgroundColor: AppColors.taskRed) { showMyTasks = true }
                    statCard(title: "Takım Görevleri", value: "5", icon: "person.2.fill", backgroundColor: AppColors.teamYellow) { showTeamTasks = true }
                }
                HStack(spacing: 12) {
                    statCard(title: "Yaklaşan", value: "2", icon: "calendar.badge.clock", backgroundColor: AppColors.feedbackOrange) { showUpcoming = true }
                    statCard(title: "Verimlilik", value: "%85", icon: "chart.line.uptrend.xyaxis", backgroundColor: AppColors.activityPurple) { showPerformance = true }
                }
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // İkon kutucuğu (Beyaz kare, siyah kenarlık)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(backgroundColor)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .border(Color.black, width: 2)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(value)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 125, alignment: .leading)
            .brutalistCard(color: backgroundColor, shadow: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Aktiviteler").font(.system(size: 20, weight: .black)).foregroundColor(AppColors.textPrimary)
            activityCard(icon: "sparkles", title: "Temizlik Bildirimi", subtitle: "Ofis temizlik durumunu bildir", color: AppColors.activityPurple) { showCleaningReport = true }
            activityCard(icon: "message.fill", title: "Takıma Geri Bildirim", subtitle: "Takımınıza mesaj gönderin", color: AppColors.feedbackOrange) { showFeedback = true }
        }
    }
    
    private func activityCard(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            ZStack(alignment: .bottomTrailing) {
                HStack(spacing: 14) {
                    // İkon kutucuğu
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .border(Color.black, width: 2)
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(color)
                    }
                    .frame(width: 44, height: 44)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                        Text(subtitle)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.square.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .brutalistCard(color: color, shadow: 4)
                
                // Bazı kartlarda buton olabilir
                if title.contains("Geri Bildirim") {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 40, height: 40)
                        .overlay(Image(systemName: "plus").font(.system(size: 18, weight: .black)).foregroundColor(.white))
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .offset(x: -8, y: -8)
                }
            }
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

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Detail Sheets

struct NotificationsSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                notificationItem(title: "Yeni görev atandı", subtitle: "Proje sunumu hazırla", time: "5 dk önce", color: AppColors.taskRed)
                notificationItem(title: "Temizlik tamamlandı", subtitle: "Ofis temizliği yapıldı", time: "1 saat önce", color: AppColors.success)
                notificationItem(title: "Toplantı hatırlatması", subtitle: "Takım toplantısı 15:00'te", time: "2 saat önce", color: AppColors.feedbackOrange)
                Spacer()
            }
            .padding()
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
    
    private func notificationItem(title: String, subtitle: String, time: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle().fill(color).frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 15, weight: .semibold))
                Text(subtitle).font(.system(size: 13)).foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Text(time).font(.system(size: 11)).foregroundColor(AppColors.textTertiary)
        }
        .padding(12)
        .background(AppColors.background)
        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
    }
}

struct TeamDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "building.2.fill").font(.system(size: 60)).foregroundColor(AppColors.companyBlue)
                    .frame(width: 100, height: 100).background(AppColors.backgroundSecondary)
                    .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                Text(TeamService.shared.currentTeam?.name ?? "Panelim").font(.system(size: 24, weight: .bold))
                Text("Yazılım Departmanı").font(.system(size: 16)).foregroundColor(AppColors.textSecondary)
                HStack(spacing: 30) {
                    statItem(value: "12", label: "Üye")
                    statItem(value: "45", label: "Görev")
                    statItem(value: "89%", label: "Verimlilik")
                }.padding(.top, 20)
                Spacer()
            }
            .padding()
            .navigationTitle("Takım Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.activityPurple)
            Text(label).font(.system(size: 13)).foregroundColor(AppColors.textSecondary)
        }
    }
}

struct MyTasksSheet: View {
    @Environment(\.dismiss) var dismiss
    let tasks: [OfficeTask]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        HStack(spacing: 12) {
                            Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.status == .completed ? AppColors.success : AppColors.border)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title ?? "İsimsiz Görev").font(.system(size: 15, weight: .semibold))
                                Text(task.description ?? "").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(AppColors.background)
                        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                    }
                }
                .padding()
            }
            .navigationTitle("Görevlerim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
}

struct TeamTasksSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                teamTaskItem(name: "Ahmet", task: "API Entegrasyonu", status: "Devam Ediyor", color: AppColors.feedbackOrange)
                teamTaskItem(name: "Mehmet", task: "UI Tasarım", status: "Tamamlandı", color: AppColors.success)
                teamTaskItem(name: "Ayşe", task: "Test Yazımı", status: "Başlamadı", color: AppColors.textTertiary)
                teamTaskItem(name: "Fatma", task: "Dokümantasyon", status: "Devam Ediyor", color: AppColors.feedbackOrange)
                teamTaskItem(name: "Ali", task: "Backend Geliştirme", status: "Devam Ediyor", color: AppColors.feedbackOrange)
                Spacer()
            }
            .padding()
            .navigationTitle("Takım Görevleri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
    private func teamTaskItem(name: String, task: String, status: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle().fill(AppColors.activityPurple).frame(width: 36, height: 36)
                .overlay(Text(String(name.prefix(1))).font(.system(size: 14, weight: .bold)).foregroundColor(.white))
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 14, weight: .semibold))
                Text(task).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Text(status).font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 10).padding(.vertical, 5).background(color).border(Color.black, width: 1)
        }
        .padding(12)
        .background(AppColors.background)
        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
    }
}

struct UpcomingSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                upcomingItem(title: "Proje Sunumu", date: "Yarın, 14:00", type: "Toplantı", color: AppColors.taskRed)
                upcomingItem(title: "Sprint Planlama", date: "Çarşamba, 10:00", type: "Toplantı", color: AppColors.feedbackOrange)
                upcomingItem(title: "Kod İnceleme", date: "Cuma, 15:30", type: "Görev", color: AppColors.activityPurple)
                Spacer()
            }
            .padding()
            .navigationTitle("Yaklaşan Eylemler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
    private func upcomingItem(title: String, date: String, type: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Rectangle().fill(color).frame(width: 4, height: 50)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 15, weight: .semibold))
                Text(date).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Text(type).font(.system(size: 11, weight: .bold)).foregroundColor(color)
        }
        .padding(12)
        .background(AppColors.background)
        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
    }
}

struct PerformanceSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("85%").font(.system(size: 72, weight: .black)).foregroundColor(AppColors.activityPurple)
                Text("Genel Verimlilik").font(.system(size: 16)).foregroundColor(AppColors.textSecondary)
                
                VStack(spacing: 16) {
                    performanceRow(label: "Tamamlanan Görevler", value: "42/50", percentage: 0.84)
                    performanceRow(label: "Zamanında Teslim", value: "38/42", percentage: 0.9)
                    performanceRow(label: "Kalite Puanı", value: "4.2/5", percentage: 0.84)
                }
                .padding()
                .background(AppColors.backgroundSecondary)
                .border(AppColors.border, width: 2)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Verimlilik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
    private func performanceRow(label: String, value: String, percentage: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label).font(.system(size: 14)).foregroundColor(AppColors.textSecondary)
                Spacer()
                Text(value).font(.system(size: 14, weight: .bold))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(AppColors.border.opacity(0.3)).frame(height: 8)
                    Rectangle().fill(AppColors.activityPurple).frame(width: geo.size.width * percentage, height: 8)
                }
                .border(Color.black, width: 1)
            }.frame(height: 8)
        }
    }
}

struct CleaningReportSheetHome: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedStatus: CleaningOption = .clean
    
    enum CleaningOption: String, CaseIterable {
        case clean = "Temiz"
        case needsCleaning = "Temizlik Gerekli"
        case urgent = "Acil Temizlik"
        
        var color: Color {
            switch self {
            case .clean: return AppColors.success
            case .needsCleaning: return AppColors.feedbackOrange
            case .urgent: return AppColors.taskRed
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Ofis Temizlik Durumu").font(.system(size: 16)).foregroundColor(AppColors.textSecondary)
                
                ForEach(CleaningOption.allCases, id: \.self) { option in
                    Button(action: { selectedStatus = option }) {
                        HStack {
                            Image(systemName: selectedStatus == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedStatus == option ? option.color : AppColors.border)
                            Text(option.rawValue).font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                        .padding(16)
                        .background(selectedStatus == option ? option.color.opacity(0.1) : AppColors.background)
                        .overlay(Rectangle().stroke(selectedStatus == option ? option.color : AppColors.border, lineWidth: 2))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: { dismiss() }) {
                    Text("Durumu Kaydet")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.activityPurple)
                        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Temizlik Bildirimi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
}

struct FeedbackSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText = ""
    @State private var selectedType: FeedbackType = .general
    
    enum FeedbackType: String, CaseIterable {
        case general = "Genel"
        case appreciation = "Teşekkür"
        case suggestion = "Öneri"
        case issue = "Sorun"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Feedback type
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            Button(action: { selectedType = type }) {
                                Text(type.rawValue)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(selectedType == type ? .white : AppColors.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedType == type ? AppColors.activityPurple : AppColors.background)
                                    .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                            }
                        }
                    }
                }
                
                TextField("Geri bildiriminizi yazın...", text: $feedbackText, axis: .vertical)
                    .font(.system(size: 15))
                    .lineLimit(5...10)
                    .padding(14)
                    .background(AppColors.backgroundSecondary)
                    .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Gönder")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(feedbackText.isEmpty ? AppColors.textTertiary : AppColors.feedbackOrange)
                    .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                }
                .disabled(feedbackText.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Takıma Geri Bildirim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
    }
}

#Preview {
    HomeScreen()
}
