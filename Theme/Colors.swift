import SwiftUI

/// Base of Office - Neo-Brutalism Color System
/// Canlı ve mat renkler ile kalın kenarlıklar için tasarlandı
struct AppColors {
    // MARK: - Primary Colors
    
    /// Görevler ve Hata durumları için kırmızı
    static let taskRed = Color(hex: "#FF183A")
    
    /// Takım görevleri için sarı
    static let teamYellow = Color(hex: "#D1D815")
    
    /// Aktivite ve verimlilik için mor
    static let activityPurple = Color(hex: "#B61AFF")
    
    /// Geri bildirim ve yaklaşan görevler için turuncu
    static let feedbackOrange = Color(hex: "#F7931E")
    
    /// Başarı durumları için yeşil
    static let successGreen = Color(hex: "#06D6A0")
    
    // MARK: - Neutral Colors
    
    /// Ana arka plan rengi
    static let background = Color(hex: "#FFFFFF")
    
    /// İkincil arka plan (açık gri)
    static let backgroundSecondary = Color(hex: "#F8F9FA")
    
    /// Kenarlıklar ve gölgeler için siyah
    static let border = Color(hex: "#000000")
    
    /// Metin renkleri
    static let textPrimary = Color(hex: "#1A1A1A")
    static let textSecondary = Color(hex: "#6C757D")
    static let textLight = Color(hex: "#ADB5BD")
    
    // MARK: - Status Colors
    
    /// Temizlik durumu - Temiz
    static let cleanGreen = Color(hex: "#06D6A0")
    
    /// Temizlik durumu - Kirli
    static let dirtyRed = Color(hex: "#E63946")
    
    // MARK: - Role Colors
    
    /// Şirket paneli
    static let companyBlue = Color(hex: "#457B9D")
    
    /// İş ortağı paneli
    static let partnerPurple = Color(hex: "#9D4EDD")
    
    /// Bireysel panel
    static let individualOrange = Color(hex: "#F4A261")
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
