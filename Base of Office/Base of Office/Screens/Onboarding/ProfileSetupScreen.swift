import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI

struct ProfileSetupScreen: View {
    @ObservedObject private var authService = AuthService.shared
    @State private var username: String = ""
    @State private var selectedAvatar: String = "person.circle.fill"
    @State private var isLoading = false
    
    // Photo Selection
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
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
                    // Avatar & Photo Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Profil Fotoğrafı veya Avatar")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 20) {
                            // Selected Preview
                            ZStack {
                                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: selectedAvatar)
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            .frame(width: 80, height: 80)
                            .background(AppColors.background)
                            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                            .background(Rectangle().fill(Color.black).offset(x: 3, y: 3))
                            
                            // Photo Picker Button
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                VStack(spacing: 4) {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 20))
                                    Text("Fotoğraf Seç")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 100, height: 80)
                                .background(Color.neoLime)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                                .background(Rectangle().fill(Color.black).offset(x: 3, y: 3))
                            }
                        }
                        .padding(.bottom, 8)
                        
                        Text("Veya avatar seçin:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textTertiary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(avatars, id: \.self) { avatar in
                                    Button(action: { 
                                        selectedAvatar = avatar
                                        selectedImageData = nil 
                                        selectedItem = nil
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }) {
                                        Image(systemName: avatar)
                                            .font(.system(size: 30))
                                            .foregroundColor(selectedAvatar == avatar && selectedImageData == nil ? .white : AppColors.textPrimary)
                                            .frame(width: 60, height: 60)
                                            .background(selectedAvatar == avatar && selectedImageData == nil ? AppColors.primary : AppColors.background)
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
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
    
    private func prefillInfo() {
        if let googleName = authService.currentUser?.fullName, !googleName.isEmpty, username.isEmpty {
            username = googleName.replacingOccurrences(of: " ", with: "_").lowercased()
        }
    }
    
    private func saveProfile() {
        let currentAuthUser = authService.currentUser
        guard let userId = currentAuthUser?.id ?? FirebaseConfig.shared.auth.currentUser?.uid else {
            print("❌ No User ID found")
            return
        }
        
        isLoading = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let db = FirebaseConfig.shared.db
        
        var updatedUser = User(
            id: userId,
            email: currentAuthUser?.email ?? FirebaseConfig.shared.auth.currentUser?.email,
            fullName: currentAuthUser?.fullName ?? FirebaseConfig.shared.auth.currentUser?.displayName,
            username: username,
            role: .user
        )
        
        updatedUser.profileImageURL = selectedImageData != nil ? "custom_photo" : selectedAvatar
        
        let data: [String: Any] = [
            "id": userId,
            "email": updatedUser.email ?? "",
            "fullName": currentAuthUser?.fullName ?? "",
            "username": username,
            "role": "user",
            "profileImageURL": updatedUser.profileImageURL ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        Task {
            do {
                print("🔍 Attempting to save profile for user: \(userId)")
                try await db.collection(FirestoreCollections.users).document(userId).setData(data, merge: true)
                
                await MainActor.run {
                    authService.currentUser = updatedUser
                    authService.needsProfileSetup = false
                    isLoading = false
                    print("✅ Profile saved successfully")
                }
            } catch {
                print("❌ Error saving profile: \(error.localizedDescription)")
                await MainActor.run { 
                    isLoading = false 
                }
            }
        }
    }
}
