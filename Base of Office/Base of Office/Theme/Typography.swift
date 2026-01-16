import SwiftUI

/// Base of Office - Typography System
/// Sistem fontu ile Neo-Brutalism tasarım
struct AppTypography {
    // MARK: - Font Weights
    
    static let light: Font.Weight = .light
    static let regular: Font.Weight = .regular
    static let medium: Font.Weight = .medium
    static let semiBold: Font.Weight = .semibold
    static let bold: Font.Weight = .bold
    static let black: Font.Weight = .black
    
    // MARK: - Font Sizes
    
    static func largeTitle(weight: Font.Weight = .semibold) -> Font {
        return Font.system(size: 34, weight: weight)
    }
    
    static func title1(weight: Font.Weight = .semibold) -> Font {
        return Font.system(size: 28, weight: weight)
    }
    
    static func title2(weight: Font.Weight = .semibold) -> Font {
        return Font.system(size: 22, weight: weight)
    }
    
    static func title3(weight: Font.Weight = .medium) -> Font {
        return Font.system(size: 20, weight: weight)
    }
    
    static func headline(weight: Font.Weight = .semibold) -> Font {
        return Font.system(size: 17, weight: weight)
    }
    
    static func body(weight: Font.Weight = .regular) -> Font {
        return Font.system(size: 17, weight: weight)
    }
    
    static func callout(weight: Font.Weight = .regular) -> Font {
        return Font.system(size: 16, weight: weight)
    }
    
    static func subheadline(weight: Font.Weight = .regular) -> Font {
        return Font.system(size: 15, weight: weight)
    }
    
    static func footnote(weight: Font.Weight = .regular) -> Font {
        return Font.system(size: 13, weight: weight)
    }
    
    static func caption1(weight: Font.Weight = .regular) -> Font {
        return Font.system(size: 12, weight: weight)
    }
    
    static func caption2(weight: Font.Weight = .regular) -> Font {
        return Font.system(size: 11, weight: weight)
    }
}

// MARK: - Text Modifiers

extension Text {
    func brutalistTitle() -> some View {
        self
            .font(AppTypography.title1(weight: .bold))
            .foregroundColor(AppColors.textPrimary)
    }
    
    func brutalistSubtitle() -> some View {
        self
            .font(AppTypography.headline(weight: .semibold))
            .foregroundColor(AppColors.textSecondary)
    }
    
    func brutalistBody() -> some View {
        self
            .font(AppTypography.body())
            .foregroundColor(AppColors.textPrimary)
    }
    
    func brutalistCaption() -> some View {
        self
            .font(AppTypography.caption1())
            .foregroundColor(AppColors.textTertiary)
    }
}
