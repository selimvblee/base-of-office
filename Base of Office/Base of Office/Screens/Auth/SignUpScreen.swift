import SwiftUI

/// Kayıt Ekranı - Neo-Brutalism Tasarım
struct SignUpScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .individual
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo ve Başlık
                    VStack(spacing: 16) {
                        Text("base")
                            .font(AppTypography.largeTitle(weight: AppTypography.black))
                            .foregroundColor(AppColors.textPrimary)
                        +
                        Text("of")
                            .font(AppTypography.largeTitle(weight: AppTypography.black))
                            .foregroundColor(AppColors.taskRed)
                        
                        Text("Yeni Hesap Oluştur")
                            .font(AppTypography.title3(weight: AppTypography.semiBold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        BrutalistTextField(
                            placeholder: "Ad Soyad",
                            icon: "person.fill",
                            text: $fullName
                        )
                        
                        BrutalistTextField(
                            placeholder: "E-posta",
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
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
                    
                    // Create Account Button
                    VStack(spacing: 16) {
                        BrutalistButton.task(title: "Hesap Oluştur", icon: "checkmark.circle.fill") {
                            createAccount()
                        }
                        .padding(.horizontal, 24)
                        
                        // Sign In Link
                        HStack(spacing: 4) {
                            Text("Zaten hesabınız var mı?")
                                .font(AppTypography.callout())
                                .foregroundColor(AppColors.textSecondary)
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Giriş Yap")
                                    .font(AppTypography.callout(weight: AppTypography.bold))
                                    .foregroundColor(AppColors.taskRed)
                            }
                        }
                    }
                    
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
        .navigationBarTitleDisplayMode(.inline)
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createAccount() {
        // Validation
        guard !fullName.isEmpty else {
            errorMessage = "Lütfen adınızı ve soyadınızı girin"
            showError = true
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi girin"
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
                try await authService.signUp(
                    email: email,
                    password: password,
                    fullName: fullName,
                    role: selectedRole
                )
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpScreen()
    }
}
