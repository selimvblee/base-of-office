import SwiftUI

/// Base of Office - Neo-Brutalism Shadow System
/// Yumuşak gölge YOK - Sadece sert, siyah ve kaydırılmış katı gölgeler
struct AppShadows {
    // MARK: - Hard Shadows (Sert Gölgeler)
    
    /// Küçük kartlar için sert siyah gölge
    static let small = ShadowStyle(
        color: Color.black,
        radius: 0,
        x: 2,
        y: 2
    )
    
    /// Orta boyutlu kartlar için sert siyah gölge
    static let medium = ShadowStyle(
        color: Color.black,
        radius: 0,
        x: 2,
        y: 2
    )
    
    /// Büyük kartlar ve modaller için sert siyah gölge
    static let large = ShadowStyle(
        color: Color.black,
        radius: 0,
        x: 4,
        y: 4
    )
    
    /// Butonlar için sert siyah gölge
    static let button = ShadowStyle(
        color: Color.black,
        radius: 0,
        x: 2,
        y: 2
    )
    
    /// Basılı buton gölgesi (daha sönük veya sıfır ofset)
    static let buttonPressed = ShadowStyle(
        color: Color.black,
        radius: 0,
        x: 1,
        y: 1
    )
}

// MARK: - Shadow Style Model

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extension for Shadows

extension View {
    /// Neo-Brutalism sert gölge uygula (Metin kopyalamaz)
    func brutalistShadow(_ style: ShadowStyle = AppShadows.medium) -> some View {
        self
            .background(
                Rectangle()
                    .fill(style.color)
                    .offset(x: style.x, y: style.y)
            )
            .padding(.trailing, style.x)
            .padding(.bottom, style.y)
    }
    
    /// Küçük sert gölge
    func smallBrutalistShadow() -> some View {
        self.brutalistShadow(AppShadows.small)
    }
    
    /// Orta sert gölge
    func mediumBrutalistShadow() -> some View {
        self.brutalistShadow(AppShadows.medium)
    }
    
    /// Büyük sert gölge
    func largeBrutalistShadow() -> some View {
        self.brutalistShadow(AppShadows.large)
    }
}
