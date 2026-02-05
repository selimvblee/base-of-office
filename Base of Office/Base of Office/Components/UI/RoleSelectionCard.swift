import SwiftUI

/// Rol Seçim Kartı - Neo-Brutalism Tasarım
struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        switch role {
        case .founder: return AppColors.companyBlue
        case .manager: return AppColors.teamYellow
        case .user: return AppColors.primary
        case .partner: return AppColors.activityPurple
        case .individual: return AppColors.feedbackOrange
        }
    }
    
    private var icon: String {
        switch role {
        case .founder: return "building.2.fill"
        case .manager: return "person.2.fill"
        case .user: return "person.fill"
        case .partner: return "person.3.fill"
        case .individual: return "person.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(AppTypography.title3(weight: AppTypography.bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.border, lineWidth: 2)
                    )
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(role.displayName)
                        .font(AppTypography.headline(weight: AppTypography.semiBold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(roleDescription(role))
                        .font(AppTypography.caption1())
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(AppTypography.title3(weight: AppTypography.bold))
                    .foregroundColor(isSelected ? Color.green : AppColors.textTertiary)
            }
            .padding(12)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? AppColors.textPrimary : AppColors.border,
                        lineWidth: isSelected ? 3 : 2
                    )
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func roleDescription(_ role: UserRole) -> String {
        switch role {
        case .founder:
            return "Şirket kurucusu ve genel yönetici"
        case .manager:
            return "Ekip yöneticisi"
        case .user:
            return "Şirket çalışanı"
        case .partner:
            return "Dış hizmet sağlayıcı"
        case .individual:
            return "Bireysel kullanım"
        }
    }
}
