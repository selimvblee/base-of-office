import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UIKit

/// Authentication Service
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var needsProfileSetup = false
    @Published var errorMessage: String?
    
    private let auth = FirebaseConfig.shared.auth
    private let db = FirebaseConfig.shared.db
    
    init() {
        checkAuthStatus()
    }
    
    /// Demo giriş (test için)
    func loginDemo() {
        let demoUser = User(
            id: "demo-user",
            email: "demo@baseofoffice.com",
            fullName: "Demo Kullanıcı",
            role: .founder,
            teamId: "demo-team"
        )
        
        self.currentUser = demoUser
        self.isAuthenticated = true
        print("✅ Demo user logged in")
    }
    
    /// Kullanıcı oturum durumunu kontrol et
    func checkAuthStatus() {
        auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.fetchUserData(userId: firebaseUser.uid)
            } else {
                self?.currentUser = nil
                self?.isAuthenticated = false
            }
        }
    }
    
    /// Kullanıcı verilerini Firestore'dan çek
    private func fetchUserData(userId: String) {
        db.collection(FirestoreCollections.users)
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching user data: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, snapshot.exists {
                    do {
                        let user = try snapshot.data(as: User.self)
                        DispatchQueue.main.async {
                            self?.currentUser = user
                            self?.isAuthenticated = true
                            self?.needsProfileSetup = (user.username == nil || user.username?.isEmpty == true)
                        }
                    } catch {
                        print("❌ Error decoding user: \(error)")
                        // ... decoding error handling remains same ...
                    }
                } else if snapshot?.exists == false {
                    DispatchQueue.main.async {
                        let firebaseUser = self?.auth.currentUser
                        self?.currentUser = User(
                            id: firebaseUser?.uid ?? userId,
                            email: firebaseUser?.email ?? "",
                            fullName: firebaseUser?.displayName ?? ""
                        )
                        self?.isAuthenticated = true
                        self?.needsProfileSetup = true
                    }
                }
            }
    }
    
    /// Google ile giriş yap
    @MainActor
    func signInWithGoogle() async throws {
        print("🔍 Starting Google Sign-In process...")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Root view controller not found")
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Root view controller bulunamadı"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Showing Google Sign-In UI...")
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            print("✅ Google Sign-In UI success: \(result.user.profile?.email ?? "no email")")
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("❌ Google ID token missing")
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google ID token alınamadı"])
            }
            
            print("🔍 Creating Firebase credential...")
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            print("🔍 Signing in to Firebase...")
            let authResult = try await auth.signIn(with: credential)
            print("✅ Firebase Auth success: \(authResult.user.email ?? "no email")")
            
            let firebaseUser = authResult.user
            let userDoc = db.collection(FirestoreCollections.users).document(firebaseUser.uid)
            
            print("🔍 Checking Firestore for user: \(firebaseUser.uid)")
            let userSnapshot = try await userDoc.getDocument()
            
            if !userSnapshot.exists {
                print("🔍 User not found in Firestore, redirecting to setup...")
                let tempUser = User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    fullName: firebaseUser.displayName ?? "",
                    username: nil,
                    role: nil
                )
                
                self.currentUser = tempUser
                self.isAuthenticated = true
                self.needsProfileSetup = true
                self.isLoading = false
            } else {
                print("✅ User exists in Firestore, checking completeness...")
                let user = try userSnapshot.data(as: User.self)
                self.currentUser = user
                self.isAuthenticated = true
                self.needsProfileSetup = (user.username == nil || user.username?.isEmpty == true)
                self.isLoading = false
            }
        } catch {
            print("❌ Google/Firebase Sign-In Error: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            throw error
        }
    }
    
    /// Kayıt ol
    func signUp(email: String, password: String, fullName: String, role: UserRole, username: String? = nil) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            let user = User(
                id: result.user.uid,
                email: email,
                fullName: fullName,
                username: username,
                role: role
            )
            
            try db.collection(FirestoreCollections.users)
                .document(result.user.uid)
                .setData(from: user)
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
            
            print("✅ User signed up successfully: \(email)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Giriş yap (Email veya Kullanıcı Adı ile)
    func signIn(email identifier: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        var targetEmail = identifier
        
        // Eğer giriş metni @ içermiyorsa kullanıcı adı olarak kabul et
        if !identifier.contains("@") {
            do {
                let snapshot = try await db.collection(FirestoreCollections.users)
                    .whereField("username", isEqualTo: identifier)
                    .getDocuments()
                
                if let doc = snapshot.documents.first,
                   let email = doc.data()["email"] as? String {
                    targetEmail = email
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Kullanıcı adı bulunamadı"
                        self.isLoading = false
                    }
                    throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı adı bulunamadı"])
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Giriş hatası: \(error.localizedDescription)"
                    self.isLoading = false
                }
                throw error
            }
        }
        
        do {
            let result = try await auth.signIn(withEmail: targetEmail, password: password)
            fetchUserData(userId: result.user.uid)
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print("✅ User signed in successfully: \(targetEmail)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Çıkış yap
    func signOut() {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
            currentUser = nil
            isAuthenticated = false
            needsProfileSetup = false
            print("✅ User signed out successfully")
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
    
    /// Şifre sıfırlama emaili gönder
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
        print("✅ Password reset email sent to: \(email)")
    }
    
    /// Belirli bir e-postaya sahip kullanıcının tüm verilerini sil (Admin/Debug aracı)
    func deleteUserAllData(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        print("🔍 Verileri silme işlemi başlatıldı: \(email)")
        
        // 1. Kullanıcıyı bul
        let snapshot = try await db.collection(FirestoreCollections.users)
            .whereField("email", isEqualTo: email)
            .getDocuments()
        
        guard let userDoc = snapshot.documents.first else {
            print("❌ Kullanıcı bulunamadı: \(email)")
            throw NSError(domain: "AuthService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        
        let userId = userDoc.documentID
        let userData = userDoc.data()
        let teamId = userData["teamId"] as? String
        
        // 2. Kullanıcının görevlerini sil
        let tasksSnapshot = try await db.collection(FirestoreCollections.tasks)
            .whereField("assignedTo", isEqualTo: userId)
            .getDocuments()
        
        for doc in tasksSnapshot.documents {
            try await db.collection(FirestoreCollections.tasks).document(doc.documentID).delete()
        }
        
        // 3. Kullanıcının oluşturduğu görevleri de sil (isteğe bağlı, ama temizlik için iyi)
        let createdTasksSnapshot = try await db.collection(FirestoreCollections.tasks)
            .whereField("assignedBy", isEqualTo: userId)
            .getDocuments()
        
        for doc in createdTasksSnapshot.documents {
            try await db.collection(FirestoreCollections.tasks).document(doc.documentID).delete()
        }
        
        // 4. Kullanıcıyı takımlardan çıkar
        if let teamId = teamId {
            try await db.collection(FirestoreCollections.teams)
                .document(teamId)
                .updateData([
                    "members": FieldValue.arrayRemove([userId])
                ])
        }
        
        // 5. Kullanıcının aktivitelerini sil
        let activitiesSnapshot = try await db.collection(FirestoreCollections.activities)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for doc in activitiesSnapshot.documents {
            try await db.collection(FirestoreCollections.activities).document(doc.documentID).delete()
        }
        
        // 6. Kullanıcı dokümanını sil
        try await db.collection(FirestoreCollections.users).document(userId).delete()
        
        print("✅ \(email) adresine ait tüm veriler başarıyla silindi.")
    }
}
