import Foundation
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
                        }
                    } catch {
                        print("❌ Error decoding user: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    /// Google ile giriş yap
    @MainActor
    func signInWithGoogle() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Root view controller bulunamadı"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Google Sign-In UI göster
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google ID token alınamadı"])
            }
            
            // Firebase credential oluştur
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            // Firebase ile giriş yap
            let authResult = try await auth.signIn(with: credential)
            
            // Kullanıcı verisi oluştur veya güncelle
            let firebaseUser = authResult.user
            let userDoc = db.collection(FirestoreCollections.users).document(firebaseUser.uid)
            let userSnapshot = try await userDoc.getDocument()
            
            if !userSnapshot.exists {
                // Yeni kullanıcı - Firestore'a kaydet
                let newUser = User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    fullName: firebaseUser.displayName ?? "Kullanıcı",
                    role: .individual
                )
                
                try userDoc.setData(from: newUser)
                
                self.currentUser = newUser
                self.isAuthenticated = true
                self.isLoading = false
            } else {
                // Mevcut kullanıcı - verileri çek
                fetchUserData(userId: firebaseUser.uid)
                self.isLoading = false
            }
            
            print("✅ User signed in with Google: \(firebaseUser.email ?? "unknown")")
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            throw error
        }
    }
    
    /// Kayıt ol
    func signUp(email: String, password: String, fullName: String, role: User.UserRole) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            let user = User(
                id: result.user.uid,
                email: email,
                fullName: fullName,
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
    
    /// Giriş yap
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            fetchUserData(userId: result.user.uid)
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print("✅ User signed in successfully: \(email)")
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
}
