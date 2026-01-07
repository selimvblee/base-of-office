import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Authentication Service
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = FirebaseConfig.shared.auth
    private let db = FirebaseConfig.shared.db
    
    init() {
        checkAuthStatus()
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
    
    /// Kayıt ol
    func signUp(email: String, password: String, fullName: String, role: User.UserRole) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Kullanıcı verisini Firestore'a kaydet
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
    func signOut() throws {
        try auth.signOut()
        currentUser = nil
        isAuthenticated = false
        print("✅ User signed out successfully")
    }
    
    /// Şifre sıfırlama emaili gönder
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
        print("✅ Password reset email sent to: \(email)")
    }
}
