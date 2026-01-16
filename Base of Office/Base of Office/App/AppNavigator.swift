import SwiftUI

struct AppNavigator: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var teamService = TeamService.shared
    
    var body: some View {
        Group {
            if !authService.isAuthenticated {
                SignInScreen()
            } else if authService.needsProfileSetup {
                ProfileSetupScreen()
            } else {
                // Giriş yapıldıktan sonra ana dashboard
                HomeDashboardView()
            }
        }
        .animation(.spring(), value: authService.isAuthenticated)
        .animation(.spring(), value: authService.currentUser?.teamId)
    }
}

// MARK: - Sign In Screen
struct SignInScreen: View {
    @ObservedObject var authService = AuthService.shared
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showResetAlert = false
    @State private var showResetSuccess = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 16) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Base of Office")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Modern Ofis Yönetimi")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.neoRed)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                // Login Buttons
                VStack(spacing: 16) {
                    // Google Sign-In Button
                    Button(action: {
                        Task {
                            await signInWithGoogle()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 24))
                            Text("Google ile Giriş Yap")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.neoRed)
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
                    .disabled(isLoading)
                    
                    // Demo Login Button
                    Button(action: {
                        AuthService.shared.loginDemo()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 20))
                            Text("Demo Girişi Yap")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
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
                    .disabled(isLoading)
                }
                .padding(.horizontal, 24)
                
                // Loading Indicator
                if isLoading {
                    ProgressView()
                        .tint(AppColors.primary)
                        .scaleEffect(1.2)
                }
                
                Spacer().frame(height: 40)
            }
        }
    }
    
    private func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AuthService.shared.signInWithGoogle()
        } catch {
            errorMessage = "Giriş başarısız: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Onboarding Choice Screen
struct OnboardingChoiceScreen: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hoş Geldiniz!")
                            .font(.system(size: 32, weight: .black))
                        Text("Devam etmek için bir seçenek belirleyin.")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    VStack(spacing: 20) {
                        onboardingButton(
                            title: "Yeni Panel Oluştur",
                            subtitle: "Şirket kurucusu iseniz buradan başlayın.",
                            icon: "plus.app.fill",
                            color: AppColors.taskRed
                        ) {
                            navigationPath.append("create")
                        }
                        
                        onboardingButton(
                            title: "Takıma Katıl",
                            subtitle: "Size verilen davet kodu ile giriş yapın.",
                            icon: "person.badge.plus.fill",
                            color: AppColors.teamYellow
                        ) {
                            navigationPath.append("join")
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    Button("Çıkış Yap") {
                        AuthService.shared.signOut()
                    }
                    .foregroundColor(AppColors.textTertiary)
                    .font(.system(size: 14, weight: .bold))
                }
                .padding(.top, 40)
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "create" {
                    CreateTeamScreen()
                } else {
                    JoinTeamScreen()
                }
            }
        }
    }
    
    private func onboardingButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .border(Color.black, width: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(16)
            .brutalistCard(color: AppColors.background)
        }
        .buttonStyle(PlainButtonStyle())
        .buttonStyle(PlainButtonStyle())
    }
}
