import SwiftUI

/// Neo-Brutalist Geri Butonu
struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    var title: String = "Geri"
    var showTitle: Bool = true
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                
                if showTitle {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.background)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
            .background(
                Rectangle()
                    .fill(Color.black)
                    .offset(x: 2, y: 2)
            )
            .padding(.trailing, 2)
            .padding(.bottom, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Sadece ikon olan geri butonu
struct BackButtonIcon: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(AppColors.background)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                .background(
                    Rectangle()
                        .fill(Color.black)
                        .offset(x: 2, y: 2)
                )
                .padding(.trailing, 2)
                .padding(.bottom, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        BackButton()
        BackButton(title: "Ana Sayfa")
        BackButtonIcon()
    }
    .padding()
}
