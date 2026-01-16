import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

/// App Delegate - Push Notification ve Firebase Messaging Yönetimi
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // UNUserNotificationCenter delegate'i ayarla
        UNUserNotificationCenter.current().delegate = NotificationService.shared
        
        // Firebase Messaging delegate'i ayarla
        Messaging.messaging().delegate = self
        
        // Remote notification'lar için kayıt (izin alındıktan sonra)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: - Remote Notification Registration
    
    /// APNs token alındığında
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // APNs token'ı Firebase'e gönder
        Messaging.messaging().apnsToken = deviceToken
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ APNs token received: \(tokenString.prefix(20))...")
    }
    
    /// APNs kayıt başarısız olduğunda
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// Remote notification alındığında (arka plan)
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // FCM mesajını işle
        if let messageId = userInfo["gcm.message_id"] as? String {
            print("📩 Received remote notification with message ID: \(messageId)")
        }
        
        completionHandler(.newData)
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    /// FCM token alındığında veya yenilendiğinde
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("✅ FCM Token: \(token.prefix(30))...")
        
        // Token'ı NotificationCenter üzerinden yayınla
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: ["token": token]
        )
    }
}
