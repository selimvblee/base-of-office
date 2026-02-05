import SwiftUI

/// Ana Sayfa - Giriş sonrası karşılama ekranı
struct LandingPage: View {
    @ObservedObject var authService = AuthService.shared
    var onContinue: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo & Welcome
                VStack(spacing: 16) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Base of Office")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Hoş geldin, \(authService.currentUser?.username ?? authService.currentUser?.fullName ?? "Kullanıcı")!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Features
                VStack(spacing: 14) {
                    featureRow(icon: "checklist", title: "Görev Yönetimi", subtitle: "Kişisel ve takım görevlerinizi takip edin")
                    featureRow(icon: "person.3.fill", title: "Takım İşbirliği", subtitle: "Ekibinizle gerçek zamanlı çalışın")
                    featureRow(icon: "chart.bar.fill", title: "Performans", subtitle: "İlerlemelerinizi görsel olarak izleyin")
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue Button
                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        HStack {
                            Text("Devam Et")
                                .font(.system(size: 16, weight: .black))
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
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
                    
                    Button(action: {
                        AuthService.shared.signOut()
                    }) {
                        Text("Çıkış Yap")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(AppColors.primary)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
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
}

#Preview {
    LandingPage(onContinue: {})
}
