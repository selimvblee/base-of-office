import SwiftUI

/// Base of Office - Neo-Brutalism Custom Button
/// Kalın siyah kenarlıklar ve sert gölgeler ile
struct BrutalistButton: View {
    // MARK: - Properties
    
    let title: String
    let icon: String?
    let backgroundColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    // MARK: - Initializers
    
    init(
        title: String,
        icon: String? = nil,
        backgroundColor: Color = AppColors.taskRed,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(AppTypography.headline(weight: AppTypography.semiBold))
                }
                
                Text(title)
                    .font(AppTypography.headline(weight: AppTypography.bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 3)
            )
            .cornerRadius(8)
        }
        .brutalistShadow(isPressed ? AppShadows.buttonPressed : AppShadows.button)
        .offset(x: isPressed ? 2 : 0, y: isPressed ? 2 : 0)
    }
}

// MARK: - Button Variants

extension BrutalistButton {
    /// Kırmızı görev butonu
    static func task(title: String, icon: String? = nil, action: @escaping () -> Void) -> BrutalistButton {
        BrutalistButton(title: title, icon: icon, backgroundColor: AppColors.taskRed, action: action)
    }
    
    /// Sarı takım butonu
    static func team(title: String, icon: String? = nil, action: @escaping () -> Void) -> BrutalistButton {
        BrutalistButton(title: title, icon: icon, backgroundColor: AppColors.teamYellow, action: action)
    }
    
    /// Mor aktivite butonu
    static func activity(title: String, icon: String? = nil, action: @escaping () -> Void) -> BrutalistButton {
        BrutalistButton(title: title, icon: icon, backgroundColor: AppColors.activityPurple, action: action)
    }
    
    /// Turuncu geri bildirim butonu
    static func feedback(title: String, icon: String? = nil, action: @escaping () -> Void) -> BrutalistButton {
        BrutalistButton(title: title, icon: icon, backgroundColor: AppColors.feedbackOrange, action: action)
    }
    
    /// Yeşil başarı butonu
    static func success(title: String, icon: String? = nil, action: @escaping () -> Void) -> BrutalistButton {
        BrutalistButton(title: title, icon: icon, backgroundColor: AppColors.successGreen, action: action)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        BrutalistButton.task(title: "Görev Oluştur", icon: "plus.circle.fill") {
            print("Task button tapped")
        }
        
        BrutalistButton.team(title: "Takım Oluştur", icon: "person.3.fill") {
            print("Team button tapped")
        }
        
        BrutalistButton.activity(title: "Aktivite Görüntüle", icon: "chart.bar.fill") {
            print("Activity button tapped")
        }
        
        BrutalistButton.feedback(title: "Geri Bildirim", icon: "exclamationmark.bubble.fill") {
            print("Feedback button tapped")
        }
        
        BrutalistButton.success(title: "Tamamla", icon: "checkmark.circle.fill") {
            print("Success button tapped")
        }
    }
    .padding()
    .background(AppColors.background)
}
