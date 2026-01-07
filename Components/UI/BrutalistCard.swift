import SwiftUI

/// Base of Office - Neo-Brutalism Custom Card
/// Kalın siyah kenarlıklar ve sert gölgeler ile
struct BrutalistCard<Content: View>: View {
    // MARK: - Properties
    
    let backgroundColor: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let shadowStyle: ShadowStyle
    let content: Content
    
    // MARK: - Initializers
    
    init(
        backgroundColor: Color = .white,
        borderWidth: CGFloat = 3,
        cornerRadius: CGFloat = 12,
        shadowStyle: ShadowStyle = AppShadows.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.content = content()
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.border, lineWidth: borderWidth)
            )
            .brutalistShadow(shadowStyle)
    }
}

// MARK: - Quick Stats Card

struct QuickStatsCard: View {
    let title: String
    let value: String
    let icon: String
    let backgroundColor: Color
    let size: CardSize
    
    enum CardSize {
        case small, medium, large
        
        var height: CGFloat {
            switch self {
            case .small: return 100
            case .medium: return 120
            case .large: return 150
            }
        }
    }
    
    var body: some View {
        BrutalistCard(backgroundColor: backgroundColor) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(AppTypography.title2(weight: AppTypography.bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Spacer()
                
                Text(value)
                    .font(AppTypography.largeTitle(weight: AppTypography.black))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(AppTypography.callout(weight: AppTypography.medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
            .frame(height: size.height)
        }
    }
}

// MARK: - Team Card

struct TeamCard: View {
    let teamName: String
    let description: String
    let memberCount: Int
    let backgroundColor: Color
    
    var body: some View {
        BrutalistCard(backgroundColor: backgroundColor) {
            HStack(spacing: 12) {
                Image(systemName: "building.2.fill")
                    .font(AppTypography.title2(weight: AppTypography.bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(AppColors.border.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamName)
                        .font(AppTypography.headline(weight: AppTypography.bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(AppTypography.caption1())
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(memberCount)")
                        .font(AppTypography.title3(weight: AppTypography.bold))
                        .foregroundColor(.white)
                    
                    Text("Üye")
                        .font(AppTypography.caption2())
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Activity Card

struct ActivityCard: View {
    let title: String
    let description: String
    let time: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        BrutalistCard(backgroundColor: .white) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(AppTypography.title3(weight: AppTypography.bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(iconColor)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.headline(weight: AppTypography.semiBold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(description)
                        .font(AppTypography.caption1())
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(time)
                    .font(AppTypography.caption2())
                    .foregroundColor(AppColors.textLight)
            }
            .padding(12)
        }
    }
}

// MARK: - Cleaning Status Card

struct CleaningStatusCard: View {
    let location: String
    let isClean: Bool
    
    var body: some View {
        BrutalistCard(
            backgroundColor: isClean ? AppColors.cleanGreen : AppColors.dirtyRed,
            shadowStyle: AppShadows.small
        ) {
            HStack(spacing: 12) {
                Image(systemName: isClean ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(AppTypography.title3(weight: AppTypography.bold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(location)
                        .font(AppTypography.headline(weight: AppTypography.bold))
                        .foregroundColor(.white)
                    
                    Text(isClean ? "TEMİZ" : "KİRLİ")
                        .font(AppTypography.caption1(weight: AppTypography.semiBold))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(12)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // Quick Stats Cards
            HStack(spacing: 12) {
                QuickStatsCard(
                    title: "Görevlerim",
                    value: "12",
                    icon: "list.bullet.circle.fill",
                    backgroundColor: AppColors.taskRed,
                    size: .medium
                )
                
                QuickStatsCard(
                    title: "Takım",
                    value: "8",
                    icon: "person.3.fill",
                    backgroundColor: AppColors.teamYellow,
                    size: .medium
                )
            }
            
            // Team Card
            TeamCard(
                teamName: "Base of Agency",
                description: "Dijital pazarlama ve yazılım geliştirme",
                memberCount: 12,
                backgroundColor: AppColors.taskRed
            )
            
            // Activity Card
            ActivityCard(
                title: "Yeni Görev Atandı",
                description: "Temizlik görevleri güncellendi",
                time: "2 dk önce",
                icon: "bell.fill",
                iconColor: AppColors.activityPurple
            )
            
            // Cleaning Status Cards
            CleaningStatusCard(location: "Mutfak", isClean: true)
            CleaningStatusCard(location: "Toplantı Odası", isClean: false)
        }
        .padding()
    }
    .background(AppColors.background)
}
