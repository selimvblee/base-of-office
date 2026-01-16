import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

/// Firebase Yapılandırma ve Başlatma
class FirebaseConfig {
    static let shared = FirebaseConfig()
    
    private init() {}
    
    /// Firebase'i başlat
    func configure() {
        FirebaseApp.configure()
        
        // Firestore ayarları
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
        
        print("✅ Firebase configured successfully")
    }
    
    /// Firestore referansı
    var db: Firestore {
        return Firestore.firestore()
    }
    
    /// Auth referansı
    var auth: Auth {
        return Auth.auth()
    }
    
    /// Storage referansı (ileride kullanılabilir)
    // var storage: Storage {
    //     return Storage.storage()
    // }
}

/// Firestore Collection İsimleri
struct FirestoreCollections {
    static let users = "users"
    static let teams = "teams"
    static let tasks = "tasks"
    static let activities = "activities"
    static let cleaningStatus = "cleaning_status"
    static let partnerRequests = "partner_requests"
    static let notifications = "notifications"
}
