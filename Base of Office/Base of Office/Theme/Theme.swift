import SwiftUI

/// Base of Office - Global Theme Configuration
/// Tüm arayüz elemanlarının ortak tasarım değerlerini tutar
struct AppTheme {
    // MARK: - Constants
    
    /// Kartlar için sert köşe (Neo-Brutalist: 0px)
    static let cornerRadius: CGFloat = 0
    
    /// Butonlar ve küçük elemanlar için köşe yuvarlaklığı
    static let smallCornerRadius: CGFloat = 0
    
    /// Standart kenarlık kalınlığı (İnce: 2px)
    static let borderWidth: CGFloat = 2
    
    /// Standart gölge bulanıklığı (Sert: 0)
    static let shadowBlur: CGFloat = 0
    
    /// Standart gölge ofseti (Zarif: 2px)
    static let shadowY: CGFloat = 2
    
    // MARK: - Layout
    
    static let horizontalPadding: CGFloat = 24
    static let verticalSpacing: CGFloat = 16
}

// MARK: - Global View Modifiers

struct ModernCardModifier: ViewModifier {
    var backgroundColor: Color
    var shadowY: CGFloat = AppTheme.shadowY
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: AppTheme.borderWidth)
            )
            .background(
                Rectangle()
                    .fill(Color.black)
                    .offset(x: shadowY, y: shadowY)
            )
            .padding(.trailing, shadowY)
            .padding(.bottom, shadowY)
    }
}

extension View {
    /// Modern eCommerce kart stili uygula
    func brutalistCard(
        color: Color = AppColors.background,
        shadow: CGFloat = AppTheme.shadowY
    ) -> some View {
        self.modifier(ModernCardModifier(
            backgroundColor: color,
            shadowY: shadow
        ))
    }
    
    /// Sert Neo-Brutalism buton stili uygula
    func brutalistButton(
        color: Color,
        radius: CGFloat = AppTheme.smallCornerRadius,
        border: CGFloat = AppTheme.borderWidth,
        shadow: CGFloat = 2
    ) -> some View {
        self
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .font(.system(size: 16, weight: .black))
            .foregroundColor(.white)
            .background(color)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: border)
            )
            .background(
                Rectangle()
                    .fill(Color.black)
                    .offset(x: shadow, y: shadow)
            )
            .padding(.trailing, shadow)
            .padding(.bottom, shadow)
    }
}
