import SwiftUI

/// Base of Office - Typography System
/// Hurme Sans yazı tipi ile Neo-Brutalism tasarım
struct AppTypography {
    // MARK: - Font Weights
    
    static let light = "HurmeSans-Light"
    static let regular = "HurmeSans-Regular"
    static let medium = "HurmeSans-Medium"
    static let semiBold = "HurmeSans-SemiBold"
    static let bold = "HurmeSans-Bold"
    static let black = "HurmeSans-Black"
    
    // MARK: - Font Sizes
    
    /// Başlıklar için büyük font
    static func largeTitle(weight: String = semiBold) -> Font {
        return Font.custom(weight, size: 34)
    }
    
    /// Ana başlıklar
    static func title1(weight: String = semiBold) -> Font {
        return Font.custom(weight, size: 28)
    }
    
    /// İkincil başlıklar
    static func title2(weight: String = semiBold) -> Font {
        return Font.custom(weight, size: 22)
    }
    
    /// Küçük başlıklar
    static func title3(weight: String = medium) -> Font {
        return Font.custom(weight, size: 20)
    }
    
    /// Vurgu metinleri
    static func headline(weight: String = semiBold) -> Font {
        return Font.custom(weight, size: 17)
    }
    
    /// Normal metin
    static func body(weight: String = regular) -> Font {
        return Font.custom(weight, size: 17)
    }
    
    /// Küçük metin
    static func callout(weight: String = regular) -> Font {
        return Font.custom(weight, size: 16)
    }
    
    /// Alt metin
    static func subheadline(weight: String = regular) -> Font {
        return Font.custom(weight, size: 15)
    }
    
    /// Dipnot
    static func footnote(weight: String = regular) -> Font {
        return Font.custom(weight, size: 13)
    }
    
    /// Çok küçük metin
    static func caption1(weight: String = regular) -> Font {
        return Font.custom(weight, size: 12)
    }
    
    /// En küçük metin
    static func caption2(weight: String = regular) -> Font {
        return Font.custom(weight, size: 11)
    }
}

// MARK: - Text Modifiers

extension Text {
    /// Neo-Brutalism stil başlık
    func brutalistTitle() -> some View {
        self
            .font(AppTypography.title1(weight: AppTypography.bold))
            .foregroundColor(AppColors.textPrimary)
    }
    
    /// Neo-Brutalism stil alt başlık
    func brutalistSubtitle() -> some View {
        self
            .font(AppTypography.headline(weight: AppTypography.semiBold))
            .foregroundColor(AppColors.textSecondary)
    }
    
    /// Neo-Brutalism stil body text
    func brutalistBody() -> some View {
        self
            .font(AppTypography.body())
            .foregroundColor(AppColors.textPrimary)
    }
    
    /// Neo-Brutalism stil caption
    func brutalistCaption() -> some View {
        self
            .font(AppTypography.caption1())
            .foregroundColor(AppColors.textLight)
    }
}
