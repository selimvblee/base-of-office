import SwiftUI

/// Giriş Ekranı - Neo-Brutalism Tasarım
struct SignInScreen: View {
    @StateObject private var authService = AuthService()
    
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo ve Başlık
                        VStack(spacing: 16) {
                            // Base of Office Logo
                            Text("base")
                                .font(AppTypography.largeTitle(weight: AppTypography.black))
                                .foregroundColor(AppColors.textPrimary)
                            +
                            Text("of")
                                .font(AppTypography.largeTitle(weight: AppTypography.black))
                                .foregroundColor(AppColors.taskRed)
                            
                            Text("Welcome to")
                                .font(AppTypography.callout())
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("Manage your office, elevate your operations.")
                                .font(AppTypography.caption1())
                                .foregroundColor(AppColors.textLight)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 60)
                        
                        // Form
                        VStack(spacing: 16) {
                            BrutalistTextField(
                                placeholder: "Email",
                                icon: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            BrutalistTextField(
                                placeholder: "Password",
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
                                        
                                        Text("Remember me")
                                            .font(AppTypography.caption1())
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                NavigationLink {
                                    ForgotPasswordScreen()
                                } label: {
                                    Text("Forgot Password?")
                                        .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                        .foregroundColor(AppColors.taskRed)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Sign In Button
                        VStack(spacing: 16) {
                            BrutalistButton.task(title: "Sign In", icon: nil) {
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
                                
                                Text("OR")
                                    .font(AppTypography.caption1(weight: AppTypography.semiBold))
                                    .foregroundColor(AppColors.textLight)
                                    .padding(.horizontal, 12)
                                
                                Rectangle()
                                    .fill(AppColors.border.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 24)
                            
                            // Sign Up Link
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .font(AppTypography.callout())
                                    .foregroundColor(AppColors.textSecondary)
                                
                                NavigationLink {
                                    SignUpScreen()
                                } label: {
                                    Text("Create Account")
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authService.errorMessage ?? "An error occurred")
            }
        }
    }
}

/// Şifre Sıfırlama Ekranı
struct ForgotPasswordScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService()
    
    @State private var email = ""
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Reset Password")
                        .font(AppTypography.title1(weight: AppTypography.bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(AppTypography.callout())
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 60)
                
                BrutalistTextField(
                    placeholder: "Email",
                    icon: "envelope.fill",
                    text: $email,
                    keyboardType: .emailAddress
                )
                .padding(.horizontal, 24)
                
                BrutalistButton.task(title: "Send Reset Link", icon: "paperplane.fill") {
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
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Password reset link sent to \(email)")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "An error occurred")
        }
    }
}

#Preview {
    SignInScreen()
}
