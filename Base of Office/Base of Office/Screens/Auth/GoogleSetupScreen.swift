import SwiftUI

/// Google Setup Screen - For creating username and password after Google login
struct GoogleSetupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared
    
    let email: String
    let fullName: String
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .individual
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Title
                    VStack(spacing: 16) {
                        Text("Hesap Detaylarını Oluştur")
                            .font(AppTypography.title2(weight: AppTypography.bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Google ile giriş yaptınız. Uygulama için kullanıcı adı ve şifre belirleyin.")
                            .font(AppTypography.callout())
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        BrutalistTextField(
                            placeholder: "Kullanıcı Adı",
                            icon: "person.fill",
                            text: $username
                        )
                        
                        BrutalistTextField(
                            placeholder: "Şifre",
                            icon: "lock.fill",
                            text: $password,
                            isSecure: true
                        )
                        
                        BrutalistTextField(
                            placeholder: "Şifre Tekrar",
                            icon: "lock.fill",
                            text: $confirmPassword,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Button
                    BrutalistButton.task(title: "Hesabı Oluştur ve Giriş Ekranına Dön", icon: "checkmark.circle.fill") {
                        setupAccount()
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            
            // Loading Overlay
            if authService.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func setupAccount() {
        // Validation
        guard !username.isEmpty else {
            errorMessage = "Lütfen bir kullanıcı adı girin"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalıdır"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Şifreler uyuşmuyor"
            showError = true
            return
        }
        
        Task {
            do {
                // Hesap oluştur
                try await authService.signUp(
                    email: email, 
                    password: password, 
                    fullName: fullName, 
                    role: selectedRole,
                    username: username
                )
                
                // Oturumu kapatıyoruz ki kullanıcı manuel giriş yapsın
                await MainActor.run {
                    authService.signOut()
                    // Başarılı, giriş ekranına dön
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Hesap oluşturulamadı: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
