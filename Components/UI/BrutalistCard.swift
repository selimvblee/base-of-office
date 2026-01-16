import SwiftUI

/// Base of Office - Neo-Brutalism Custom Card
/// Kalın siyah kenarlıklar ve sert gölgeler ile
struct BrutalistCard<Content: View>: View {
    // Değişkenler
    var color: Color
    var content: Content
    
    // init fonksiyonunda varsayılan değer (default value) atadık.
    init(color: Color = .white, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }

    var body: some View {
        content
            .padding() // İçerik ile kenar arasındaki boşluk
            .frame(maxWidth: .infinity, alignment: .leading) // Kartı genişletir
            .background(color) // Kart rengi
            // --- YENİ TASARIM AYARLARI ---
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 2) // Daha ince kenarlık
            )
            .background(
                Rectangle()
                    .fill(Color.black)
                    .offset(x: 2, y: 2)
            )
            .padding(.trailing, 2)
            .padding(.bottom, 2)
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
        BrutalistCard(color: backgroundColor) {
            VStack(alignment: .leading, spacing: 8) {
                // Icon with semi-transparent background
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
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
        BrutalistCard(color: backgroundColor) {
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
    var showArrow: Bool = false
    var showPlusButton: Bool = false
    
    var body: some View {
        BrutalistCard(color: iconColor) {
            HStack(spacing: 14) {
                // Icon with semi-transparent background
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !description.isEmpty {
                        Text(description)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    if !time.isEmpty {
                        Text(time)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if showPlusButton {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(AppColors.taskRed)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.border, lineWidth: 2)
                        )
                }
            }
        }
    }
}

// MARK: - Cleaning Status Card

struct CleaningStatusCard: View {
    let location: String
    let isClean: Bool
    
    var body: some View {
        BrutalistCard(
            color: isClean ? AppColors.cleanGreen : AppColors.dirtyRed
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
        }
    }
}

// MARK: - Preview

struct BrutalistCard_Previews: PreviewProvider {
    static var previews: some View {
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
}
