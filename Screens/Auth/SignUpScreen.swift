import SwiftUI

/// Kayıt Ekranı - Neo-Brutalism Tasarım
struct SignUpScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService()
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: User.UserRole = .individual
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
                        
                        Text("Create Your Account")
                            .font(AppTypography.title3(weight: AppTypography.semiBold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        BrutalistTextField(
                            placeholder: "Full Name",
                            icon: "person.fill",
                            text: $fullName
                        )
                        
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
                        
                        BrutalistTextField(
                            placeholder: "Confirm Password",
                            icon: "lock.fill",
                            text: $confirmPassword,
                            isSecure: true
                        )
                        
                        // Role Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Your Role")
                                .font(AppTypography.callout(weight: AppTypography.semiBold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: 12) {
                                ForEach(User.UserRole.allCases, id: \.self) { role in
                                    RoleSelectionCard(
                                        role: role,
                                        isSelected: selectedRole == role
                                    ) {
                                        selectedRole = role
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Create Account Button
                    VStack(spacing: 16) {
                        BrutalistButton.task(title: "Create Account", icon: "checkmark.circle.fill") {
                            createAccount()
                        }
                        .padding(.horizontal, 24)
                        
                        // Sign In Link
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .font(AppTypography.callout())
                                .foregroundColor(AppColors.textSecondary)
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Sign In")
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
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createAccount() {
        // Validation
        guard !fullName.isEmpty else {
            errorMessage = "Please enter your full name"
            showError = true
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
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

/// Rol Seçim Kartı
struct RoleSelectionCard: View {
    let role: User.UserRole
    let isSelected: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        switch role {
        case .company: return AppColors.companyBlue
        case .employee: return AppColors.teamYellow
        case .partner: return AppColors.partnerPurple
        case .individual: return AppColors.individualOrange
        }
    }
    
    private var icon: String {
        switch role {
        case .company: return "building.2.fill"
        case .employee: return "person.fill"
        case .partner: return "person.2.fill"
        case .individual: return "person.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(AppTypography.title3(weight: AppTypography.bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.border, lineWidth: 2)
                    )
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(role.displayName)
                        .font(AppTypography.headline(weight: AppTypography.semiBold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(roleDescription(role))
                        .font(AppTypography.caption1())
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(AppTypography.title3(weight: AppTypography.bold))
                    .foregroundColor(isSelected ? AppColors.successGreen : AppColors.textLight)
            }
            .padding(12)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? AppColors.successGreen : AppColors.border,
                        lineWidth: isSelected ? 3 : 2
                    )
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func roleDescription(_ role: User.UserRole) -> String {
        switch role {
        case .company:
            return "Manage teams and operations"
        case .employee:
            return "Part of a company team"
        case .partner:
            return "Provide services to companies"
        case .individual:
            return "Personal task management"
        }
    }
}

#Preview {
    NavigationStack {
        SignUpScreen()
    }
}
