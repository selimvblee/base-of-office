import SwiftUI

/// Yeni Görev Oluşturma Modalı
struct CreateTaskModal: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskService = TaskService()
    @StateObject private var teamService = TeamService()
    
    @State private var selectedType: Task.TaskType = .regular
    @State private var description = ""
    @State private var selectedAssignee: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            VStack(spacing: 24) {
                // Modal Başlık
                HStack {
                    Text("Yeni Oluştur")
                        .font(AppTypography.title2(weight: AppTypography.bold))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Tür Seçimi
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tür Seçin")
                        .font(AppTypography.caption1(weight: AppTypography.semiBold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: 12) {
                        typeButton(type: .regular, title: "Görev Ver", icon: "checkmark.circle")
                        typeButton(type: .cleaning, title: "Temizlik", icon: "sparkles")
                        typeButton(type: .issue, title: "Sorun Bildir", icon: "exclamationmark.triangle")
                    }
                }
                
                // Açıklama
                VStack(alignment: .leading, spacing: 12) {
                    BrutalistTextField(
                        placeholder: "Açıklama",
                        text: $description
                    )
                }
                
                // Atanan Kişi
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kime Gönderilsin?")
                        .font(AppTypography.caption1(weight: AppTypography.semiBold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    if teamService.teamMembers.isEmpty {
                        Text("Takımda başka üye yok")
                            .font(AppTypography.caption1())
                            .foregroundColor(AppColors.textLight)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                    } else {
                        // Üye seçme picker'ı buraya gelecek
                    }
                }
                
                // Gönder Butonu
                BrutalistButton(
                    title: "Gönder",
                    icon: nil,
                    backgroundColor: AppColors.teamYellow
                ) {
                    // Görev oluşturma aksiyonu
                    dismiss()
                }
                .padding(.top, 10)
            }
            .padding(24)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border, lineWidth: 4)
            )
            .cornerRadius(16)
            .largeBrutalistShadow()
            .padding(20)
        }
    }
    
    private func typeButton(type: Task.TaskType, title: String, icon: String) -> some View {
        Button(action: { selectedType = type }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3.bold())
                Text(title)
                    .font(AppTypography.caption2(weight: AppTypography.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selectedType == type ? AppColors.backgroundSecondary : .white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: selectedType == type ? 3 : 1)
            )
            .cornerRadius(8)
            .foregroundColor(AppColors.textPrimary)
        }
    }
}

#Preview {
    CreateTaskModal()
}
