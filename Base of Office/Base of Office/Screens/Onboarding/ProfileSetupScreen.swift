import SwiftUI
import FirebaseFirestore

struct ProfileSetupScreen: View {
    @StateObject private var authService = AuthService.shared
    @State private var username: String = ""
    @State private var selectedAvatar: String = "person.circle.fill"
    @State private var isLoading = false
    @State private var showResetAlert = false
    
    let avatars = [
        "person.circle.fill", "face.smiling.fill", "bolt.circle.fill", 
        "star.circle.fill", "heart.circle.fill", "moon.circle.fill",
        "sun.max.circle.fill", "leaf.circle.fill", "crown.fill"
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Profilini Kur")
                        .font(.system(size: 32, weight: .black))
                    Text("Topluluğa katılmak için bir kullanıcı adı ve avatar seç.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 32) {
                    // Avatar Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Avatar Seç")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(avatars, id: \.self) { avatar in
                                    Button(action: { 
                                        selectedAvatar = avatar
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }) {
                                        Image(systemName: avatar)
                                            .font(.system(size: 30))
                                            .foregroundColor(selectedAvatar == avatar ? .white : AppColors.textPrimary)
                                            .frame(width: 60, height: 60)
                                            .background(selectedAvatar == avatar ? AppColors.primary : AppColors.background)
                                            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                                            .background(
                                                Rectangle()
                                                    .fill(Color.black)
                                                    .offset(x: 2, y: 2)
                                            )
                                    }
                                    .padding(.bottom, 4)
                                    .padding(.trailing, 4)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    
                    // Username Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kullanıcı Adı")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                        BrutalistTextField(placeholder: "Örn: neo_ofis", text: $username)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: saveProfile) {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        HStack {
                            Text("Kaydet")
                            Image(systemName: "checkmark.seal.fill")
                        }
                        .font(.system(size: 16, weight: .bold))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .brutalistButton(color: username.isEmpty ? AppColors.textTertiary : AppColors.primary)
                .disabled(username.isEmpty || isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .padding(.top, 40)
        }
        .onAppear {
            prefillInfo()
        }
        .onChange(of: authService.currentUser?.id) { _ in
            prefillInfo()
        }
    }
    
    private func prefillInfo() {
        if let googleName = authService.currentUser?.fullName, !googleName.isEmpty, username.isEmpty {
            username = googleName.replacingOccurrences(of: " ", with: "_").lowercased()
        }
    }
    
    private func saveProfile() {
        guard let userId = authService.currentUser?.id, 
              let email = authService.currentUser?.email else { return }
        
        isLoading = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let db = FirebaseConfig.shared.db
        
        // Prepare updated user object
        var updatedUser = User(
            id: userId,
            email: email,
            fullName: authService.currentUser?.fullName,
            username: username,
            role: .user // Default role as roles are removed from UI
        )
        updatedUser.profileImageURL = selectedAvatar
        
        Task {
            do {
                try db.collection(FirestoreCollections.users).document(userId).setData(from: updatedUser)
                await MainActor.run {
                    authService.currentUser = updatedUser
                    authService.needsProfileSetup = false
                    isLoading = false
                    print("✅ Profile saved for user: \(username)")
                }
            } catch {
                print("❌ Error saving profile: \(error.localizedDescription)")
                await MainActor.run { 
                    authService.errorMessage = "Profil kaydedilemedi: \(error.localizedDescription)"
                    isLoading = false 
                }
            }
        }
    }
}
