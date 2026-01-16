import SwiftUI

/// Base of Office - Neo-Brutalism Color System
/// Canlı ve mat renkler ile kalın kenarlıklar için tasarlandı
struct AppColors {
    // MARK: - Primary Colors
    
    /// Ana vurgu rengi (Modern Canlı Kırmızı)
    /// Ana vurgu rengi (Vibrant Red)
    static let primary = Color(hex: "#FF183A")
    
    /// Başarı durumları (Lime Green)
    static let success = Color(hex: "#D1D815")
    
    /// Uyarı durumları (Orange)
    static let warning = Color(hex: "#F7931E")
    
    /// Hata durumları (Red)
    static let error = Color(hex: "#FF183A")
    
    // MARK: - Neutral Colors
    
    /// Ana arka plan rengi (Bembeyaz)
    static let background = Color.white
    
    /// İkincil arka plan (Beyaz)
    static let backgroundSecondary = Color.white
    
    /// Üçüncü arka plan (Beyaz)
    static let backgroundTertiary = Color.white
    
    /// Metin renkleri
    static let textPrimary = Color.black
    static let textSecondary = Color.black.opacity(0.7)
    static let textTertiary = Color.black.opacity(0.5)
    
    /// Kenarlıklar (Sert Siyah)
    static let border = Color.black
    
    // MARK: - Legacy Compatibility
    static let taskRed = Color(hex: "#FF183A")
    static let teamYellow = Color(hex: "#D1D815")
    static let activityPurple = Color(hex: "#B61AFF")
    static let feedbackOrange = Color(hex: "#F7931E")
    static let companyBlue = Color(hex: "#B61AFF")
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
