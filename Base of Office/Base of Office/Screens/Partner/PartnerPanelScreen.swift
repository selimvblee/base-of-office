import SwiftUI
import Combine

/// İş Ortağı Paneli - Dış hizmet sağlayıcılar için
struct PartnerPanelScreen: View {
    @Binding var selectedTab: Int
    @StateObject private var authService = AuthService.shared
    @State private var serviceType = ""
    @State private var description = ""
    @State private var urgency: RequestUrgency = .normal
    @State private var showSuccess = false
    @State private var showRequestDetail = false
    @State private var selectedRequest: ServiceRequest?
    @State private var requests: [ServiceRequest] = ServiceRequest.sampleRequests
    
    enum RequestUrgency: String, CaseIterable {
        case normal = "Normal"
        case urgent = "Acil"
        case critical = "Kritik"
        
        var color: Color {
            switch self {
            case .normal: return AppColors.success
            case .urgent: return AppColors.feedbackOrange
            case .critical: return AppColors.taskRed
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        quickStatsRow
                        newRequestSection
                        requestsSection
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .alert("Başarılı! ✅", isPresented: $showSuccess) {
                Button("Tamam", role: .cancel) {
                    serviceType = ""
                    description = ""
                    urgency = .normal
                }
            } message: {
                Text("Hizmet talebiniz şirket yöneticisine iletildi. En kısa sürede yanıt alacaksınız.")
            }
            .sheet(isPresented: $showRequestDetail) {
                if let request = selectedRequest {
                    RequestDetailSheet(request: request)
                }
            }
        }
    }
    
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
            
            Circle()
                .fill(AppColors.activityPurple)
                .frame(width: 44, height: 44)
                .overlay(Text(String(authService.currentUser?.username?.prefix(1) ?? authService.currentUser?.fullName?.prefix(1) ?? "P")).font(.system(size: 18, weight: .bold)).foregroundColor(.white))
                .overlay(Circle().stroke(AppColors.border, lineWidth: 2))
        }
        .padding(.top, 16)
    }
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            miniStatCard(title: "Bekleyen", value: "\(requests.filter { $0.status == .pending }.count)", icon: "clock.fill", color: AppColors.teamYellow)
            miniStatCard(title: "Onaylanan", value: "\(requests.filter { $0.status == .approved }.count)", icon: "checkmark.circle.fill", color: AppColors.success)
            miniStatCard(title: "Reddedilen", value: "\(requests.filter { $0.status == .rejected }.count)", icon: "xmark.circle.fill", color: AppColors.taskRed)
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
        .brutalistCard(color: color, shadow: 4)
    }
    
    private var newRequestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppColors.activityPurple)
                Text("Yeni Hizmet Talebi")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 14) {
                // Service Type
                TextField("Hizmet Türü (Örn: Teknik Destek)", text: $serviceType)
                    .font(.system(size: 14))
                    .padding(14)
                    .background(AppColors.background)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                
                // Description
                TextField("Detaylı açıklama...", text: $description, axis: .vertical)
                    .font(.system(size: 14))
                    .lineLimit(4...6)
                    .padding(14)
                    .background(AppColors.background)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                
                // Urgency Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Öncelik")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: 10) {
                        ForEach(RequestUrgency.allCases, id: \.self) { level in
                            urgencyButton(level: level)
                        }
                    }
                }
                
                // Submit Button
                Button(action: sendRequest) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Talep Gönder")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .brutalistButton(color: isFormValid ? AppColors.primary : AppColors.textTertiary)
                .disabled(!isFormValid)
            }
            .padding(16)
            .brutalistCard()
        }
    }
    
    private func urgencyButton(level: RequestUrgency) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                urgency = level
            }
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            Text(level.rawValue)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(urgency == level ? .white : AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(urgency == level ? level.color : AppColors.background)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                .background(
                    Rectangle()
                        .fill(Color.black)
                        .offset(x: 2, y: 2)
                )
                .padding(.trailing, 2)
                .padding(.bottom, 2)
        }
    }
    
    private var isFormValid: Bool {
        !serviceType.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func sendRequest() {
        guard isFormValid else { return }
        
        let newRequest = ServiceRequest(
            id: UUID().uuidString,
            title: serviceType.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            date: Date(),
            status: .pending,
            urgency: urgency
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            requests.insert(newRequest, at: 0)
        }
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        showSuccess = true
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
            
            if requests.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textTertiary)
                    Text("Henüz talep yok")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(requests) { request in
                        requestCard(request: request)
                    }
                }
            }
        }
    }
    
    private func requestCard(request: ServiceRequest) -> some View {
        Button(action: {
            selectedRequest = request
            showRequestDetail = true
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 14) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(AppColors.activityPurple)
                    .border(Color.black, width: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(request.dateString)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text(request.status.displayName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(request.status.color)
                    .border(Color.black, width: 1)
            }
            .padding(14)
            .brutalistCard(color: AppColors.background, shadow: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Service Request Model

struct ServiceRequest: Identifiable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let status: RequestStatus
    let urgency: PartnerPanelScreen.RequestUrgency
    
    var dateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    static let sampleRequests: [ServiceRequest] = [
        ServiceRequest(id: "1", title: "Ofis Temizliği", description: "Haftalık temizlik hizmeti", date: Date().addingTimeInterval(-3600), status: .pending, urgency: .normal),
        ServiceRequest(id: "2", title: "Teknik Destek", description: "Yazıcı arızası", date: Date().addingTimeInterval(-86400), status: .approved, urgency: .urgent),
        ServiceRequest(id: "3", title: "Güvenlik Kontrolü", description: "Aylık güvenlik denetimi", date: Date().addingTimeInterval(-172800), status: .rejected, urgency: .normal)
    ]
}

enum RequestStatus: String {
    case pending, approved, rejected
    
    var displayName: String {
        switch self {
        case .pending: return "Bekliyor"
        case .approved: return "Onaylandı"
        case .rejected: return "Reddedildi"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return AppColors.teamYellow
        case .approved: return AppColors.success
        case .rejected: return AppColors.taskRed
        }
    }
}

// MARK: - Request Detail Sheet

struct RequestDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let request: ServiceRequest
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Status Badge
                HStack {
                    Text(request.status.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(request.status.color)
                        .border(Color.black, width: 1)
                    
                    Spacer()
                    
                    Text(request.dateString)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hizmet Türü")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                    Text(request.title)
                        .font(.system(size: 18, weight: .bold))
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Açıklama")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                    Text(request.description)
                        .font(.system(size: 15))
                }
                
                // Urgency
                VStack(alignment: .leading, spacing: 8) {
                    Text("Öncelik")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                    HStack {
                        Circle()
                            .fill(request.urgency.color)
                            .frame(width: 10, height: 10)
                        Text(request.urgency.rawValue)
                            .font(.system(size: 15, weight: .medium))
                    }
                }
                
                Spacer()
                
                // Action Buttons
                if request.status == .pending {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Talebi İptal Et")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.taskRed)
                        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 2))
                    }
                }
            }
            .padding()
            .navigationTitle("Talep Detayı")
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
    PartnerPanelScreen(selectedTab: .constant(0))
}
