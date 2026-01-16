import Foundation
import FirebaseFirestore

enum UserRole: String, Codable, CaseIterable {
    case founder = "founder"
    case manager = "manager"
    case user = "user"
    case partner = "partner"
    case individual = "individual"
    
    var displayName: String {
        switch self {
        case .founder: return "Kurucu"
        case .manager: return "Yönetici"
        case .user: return "Kullanıcı"
        case .partner: return "İş Ortağı"
        case .individual: return "Bireysel"
        }
    }
}

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String?
    var fullName: String?
    var username: String?
    var role: UserRole?
    var teamId: String?
    @ServerTimestamp var createdAt: Date?
    var profileImageURL: String?
    var fcmToken: String?
    var notificationsEnabled: Bool? = true
    
    init(id: String? = nil, email: String? = nil, fullName: String? = nil, username: String? = nil, role: UserRole? = nil, teamId: String? = nil) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.username = username
        self.role = role
        self.teamId = teamId
        self.createdAt = Date()
        self.notificationsEnabled = true
    }

    // Safe Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.role = try container.decodeIfPresent(UserRole.self, forKey: .role)
        self.teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        self.fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken)
        self.notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
    }
}
