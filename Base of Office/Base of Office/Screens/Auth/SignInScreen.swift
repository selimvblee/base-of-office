import SwiftUI

/// Giriş Ekranı - Neo-Brutalism Tasarım
struct SignInScreen: View {
    @ObservedObject private var authService = AuthService.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showError = false
    @State private var showGoogleSetup = false
    @State private var googleUserEmail = ""
    @State private var googleUserFullName = ""
    
    var body: some View {
        NavigationStack {
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
                            
                            Text("Office Operations")
                                .font(AppTypography.callout())
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 60)
                        
                        // Form
                        VStack(spacing: 16) {
                            BrutalistTextField(
                                placeholder: "Kullanıcı Adı veya Email",
                                icon: "person.fill",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            BrutalistTextField(
                                placeholder: "Şifre",
                                icon: "lock.fill",
                                text: $password,
                                isSecure: true
                            )
                            
                            // Remember Me & Forgot Password
                            HStack {
                                Button(action: {
                                    rememberMe.toggle()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                            .font(AppTypography.body(weight: AppTypography.semiBold))
                                            .foregroundColor(rememberMe ? AppColors.taskRed : AppColors.textSecondary)
                                        
                                        Text("Beni Hatırla")
                                            .font(AppTypography.caption1())
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                NavigationLink {
                                    ForgotPasswordScreen()
                                } label: {
                                    Text("Şifremi Unuttum")
                                        .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                        .foregroundColor(AppColors.taskRed)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Sign In Button
                        VStack(spacing: 16) {
                            BrutalistButton.task(title: "Giriş Yap", icon: "arrow.right.circle.fill") {
                                Task {
                                    do {
                                        try await authService.signIn(email: email, password: password)
                                    } catch {
                                        showError = true
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(AppColors.border.opacity(0.3))
                                    .frame(height: 1)
                                
                                Text("VEYA")
                                    .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                    .foregroundColor(AppColors.textTertiary)
                                    .padding(.horizontal, 12)
                                
                                Rectangle()
                                    .fill(AppColors.border.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 24)
                            
                            // Google Sign In Button
                            BrutalistButton(
                                title: "Google ile Giriş Yap",
                                icon: "g.circle.fill",
                                backgroundColor: .white
                            ) {
                                Task {
                                    do {
                                        try await authService.signInWithGoogle()
                                        // Google login sonrası kullanıcı adı/şifre oluşturma ekranına yönlendir
                                        if let user = authService.currentUser,
                                           let email = user.email,
                                           let fullName = user.fullName {
                                            googleUserEmail = email
                                            googleUserFullName = fullName
                                            authService.signOut() // Oturumu kapatıp manuel girişe zorluyoruz
                                            showGoogleSetup = true
                                        }
                                    } catch {
                                        showError = true
                                    }
                                }
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            
                            // Sign Up Link
                            HStack(spacing: 4) {
                                Text("Hesabınız yok mu?")
                                    .font(AppTypography.callout())
                                    .foregroundColor(AppColors.textSecondary)
                                
                                NavigationLink {
                                    SignUpScreen()
                                } label: {
                                    Text("Hesap Oluştur")
                                        .font(AppTypography.callout(weight: AppTypography.bold))
                                        .foregroundColor(AppColors.taskRed)
                                }
                            }
                            .padding(.top, 8)
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
            .navigationDestination(isPresented: $showGoogleSetup) {
                GoogleSetupScreen(email: googleUserEmail, fullName: googleUserFullName)
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(authService.errorMessage ?? "Bir hata oluştu")
            }
        }
    }
}

/// Şifre Sıfırlama Ekranı
struct ForgotPasswordScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared
    
    @State private var email = ""
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Şifre Sıfırlama")
                        .font(AppTypography.title1(weight: AppTypography.bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("E-posta adresinizi girin, şifrenizi sıfırlamanız için size bir bağlantı gönderelim.")
                        .font(AppTypography.callout())
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 60)
                
                BrutalistTextField(
                    placeholder: "E-posta",
                    icon: "envelope.fill",
                    text: $email,
                    keyboardType: .emailAddress
                )
                .padding(.horizontal, 24)
                
                BrutalistButton.task(title: "Sıfırlama Bağlantısı Gönder", icon: "paperplane.fill") {
                    Task {
                        do {
                            try await authService.resetPassword(email: email)
                            showSuccess = true
                        } catch {
                            showError = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Başarılı", isPresented: $showSuccess) {
            Button("Tamam") {
                dismiss()
            }
        } message: {
            Text("Şifre sıfırlama bağlantısı \(email) adresine gönderildi.")
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "Bir hata oluştu")
        }
    }
}

#Preview {
    SignInScreen()
}
