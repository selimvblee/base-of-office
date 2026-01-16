import Foundation
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

/// Bildirim Servisi - Push notification ve Firestore notification yönetimi
class NotificationService: NSObject, ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    @Published var isPermissionGranted: Bool = false
    
    private let db = FirebaseConfig.shared.db
    private var listener: ListenerRegistration?
    
    static let shared = NotificationService()
    
    override init() {
        super.init()
        checkPermissionStatus()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Permission Management
    
    /// Bildirim izni durumunu kontrol et
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// Push notification izni iste
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
            return granted
        } catch {
            print("❌ Error requesting notification permission: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Remote notification'lar için kayıt ol
    @MainActor
    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - FCM Token Management
    
    /// FCM token'ı Firestore'a kaydet
    func saveFCMToken(for userId: String) async {
        do {
            guard let token = Messaging.messaging().fcmToken else {
                print("⚠️ FCM token not available yet")
                return
            }
            
            try await db.collection(FirestoreCollections.users)
                .document(userId)
                .updateData([
                    "fcmToken": token
                ])
            
            print("✅ FCM token saved successfully")
        } catch {
            print("❌ Error saving FCM token: \(error.localizedDescription)")
        }
    }
    
    /// FCM token'ı temizle (çıkış yaparken)
    func clearFCMToken(for userId: String) async {
        do {
            try await db.collection(FirestoreCollections.users)
                .document(userId)
                .updateData([
                    "fcmToken": FieldValue.delete()
                ])
            
            print("✅ FCM token cleared successfully")
        } catch {
            print("❌ Error clearing FCM token: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Notification Listening
    
    /// Kullanıcının bildirimlerini dinlemeye başla
    func startListening(for userId: String) {
        // Önceki listener'ı temizle
        listener?.remove()
        
        listener = db.collection(FirestoreCollections.notifications)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error listening to notifications: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let notifications = documents.compactMap { doc -> Notification? in
                    try? doc.data(as: Notification.self)
                }
                
                DispatchQueue.main.async {
                    self?.notifications = notifications
                    self?.unreadCount = notifications.filter { !$0.isRead }.count
                }
            }
    }
    
    /// Dinlemeyi durdur
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Notification Actions
    
    /// Bildirimi okundu olarak işaretle
    func markAsRead(notificationId: String) async {
        do {
            try await db.collection(FirestoreCollections.notifications)
                .document(notificationId)
                .updateData([
                    "isRead": true
                ])
            
            print("✅ Notification marked as read")
        } catch {
            print("❌ Error marking notification as read: \(error.localizedDescription)")
        }
    }
    
    /// Tüm bildirimleri okundu olarak işaretle
    func markAllAsRead(for userId: String) async {
        do {
            let snapshot = try await db.collection(FirestoreCollections.notifications)
                .whereField("userId", isEqualTo: userId)
                .whereField("isRead", isEqualTo: false)
                .getDocuments()
            
            let batch = db.batch()
            for document in snapshot.documents {
                batch.updateData(["isRead": true], forDocument: document.reference)
            }
            
            try await batch.commit()
            print("✅ All notifications marked as read")
        } catch {
            print("❌ Error marking all notifications as read: \(error.localizedDescription)")
        }
    }
    
    /// Bildirimi sil
    func deleteNotification(notificationId: String) async {
        do {
            try await db.collection(FirestoreCollections.notifications)
                .document(notificationId)
                .delete()
            
            print("✅ Notification deleted")
        } catch {
            print("❌ Error deleting notification: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Create Notifications (Local)
    
    /// Yerel bildirim oluştur (Firestore'a kaydet)
    func createNotification(
        for userId: String,
        title: String,
        body: String,
        type: Notification.NotificationType,
        relatedTaskId: String? = nil,
        relatedTeamId: String? = nil
    ) async {
        let notification = Notification(
            userId: userId,
            title: title,
            body: body,
            type: type,
            relatedTaskId: relatedTaskId,
            relatedTeamId: relatedTeamId
        )
        
        do {
            try db.collection(FirestoreCollections.notifications)
                .addDocument(from: notification)
            
            print("✅ Notification created successfully")
        } catch {
            print("❌ Error creating notification: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Local Notification Scheduling
    
    /// Yerel bildirim göster (FCM olmadan test için)
    func showLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error showing local notification: \(error.localizedDescription)")
            } else {
                print("✅ Local notification scheduled")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    /// Uygulama ön plandayken bildirim geldiğinde
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Ön planda bile bildirimi göster
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Kullanıcı bildirime tıkladığında
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Bildirim verilerini işle
        if let taskId = userInfo["taskId"] as? String {
            print("📱 User tapped notification for task: \(taskId)")
            // TODO: Navigate to task detail
        }
        
        completionHandler()
    }
}
