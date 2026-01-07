import Foundation
import FirebaseFirestore

/// Kullanıcı Modeli
struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var fullName: String
    var role: UserRole
    var teamId: String?
    var createdAt: Date
    var profileImageURL: String?
    
    enum UserRole: String, Codable, CaseIterable {
        case company = "company"           // Şirket yöneticisi
        case employee = "employee"         // Çalışan
        case partner = "partner"           // İş ortağı
        case individual = "individual"     // Bireysel kullanıcı
        
        var displayName: String {
            switch self {
            case .company: return "Şirket Yöneticisi"
            case .employee: return "Çalışan"
            case .partner: return "İş Ortağı"
            case .individual: return "Bireysel"
            }
        }
    }
    
    init(
        id: String? = nil,
        email: String,
        fullName: String,
        role: UserRole,
        teamId: String? = nil,
        createdAt: Date = Date(),
        profileImageURL: String? = nil
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.role = role
        self.teamId = teamId
        self.createdAt = createdAt
        self.profileImageURL = profileImageURL
    }
}

/// Takım Modeli
struct Team: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var founderId: String
    var inviteCode: String
    var members: [String]              // User IDs
    var occupations: [String]          // Meslekler
    var createdAt: Date
    var logoURL: String?
    
    init(
        id: String? = nil,
        name: String,
        description: String,
        founderId: String,
        inviteCode: String,
        members: [String] = [],
        occupations: [String] = [],
        createdAt: Date = Date(),
        logoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.founderId = founderId
        self.inviteCode = inviteCode
        self.members = members
        self.occupations = occupations
        self.createdAt = createdAt
        self.logoURL = logoURL
    }
}

/// Görev Modeli
struct Task: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var assignedTo: String             // User ID
    var assignedBy: String             // User ID
    var teamId: String
    var priority: TaskPriority
    var status: TaskStatus
    var type: TaskType
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?
    var location: String?              // Temizlik görevleri için
    
    enum TaskPriority: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
        
        var displayName: String {
            switch self {
            case .low: return "Düşük"
            case .medium: return "Orta"
            case .high: return "Yüksek"
            case .critical: return "Kritik"
            }
        }
        
        var color: String {
            switch self {
            case .low: return "successGreen"
            case .medium: return "teamYellow"
            case .high: return "feedbackOrange"
            case .critical: return "taskRed"
            }
        }
    }
    
    enum TaskStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case inProgress = "in_progress"
        case completed = "completed"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "Bekliyor"
            case .inProgress: return "Devam Ediyor"
            case .completed: return "Tamamlandı"
            case .cancelled: return "İptal Edildi"
            }
        }
    }
    
    enum TaskType: String, Codable, CaseIterable {
        case regular = "regular"           // Normal görev
        case cleaning = "cleaning"         // Temizlik görevi
        case issue = "issue"               // Sorun bildirimi
        case partnerRequest = "partner_request"  // İş ortağı talebi
        
        var displayName: String {
            switch self {
            case .regular: return "Görev"
            case .cleaning: return "Temizlik"
            case .issue: return "Sorun"
            case .partnerRequest: return "İş Ortağı Talebi"
            }
        }
        
        var icon: String {
            switch self {
            case .regular: return "list.bullet.circle.fill"
            case .cleaning: return "sparkles"
            case .issue: return "exclamationmark.triangle.fill"
            case .partnerRequest: return "person.crop.circle.badge.checkmark"
            }
        }
    }
    
    init(
        id: String? = nil,
        title: String,
        description: String,
        assignedTo: String,
        assignedBy: String,
        teamId: String,
        priority: TaskPriority = .medium,
        status: TaskStatus = .pending,
        type: TaskType = .regular,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.assignedTo = assignedTo
        self.assignedBy = assignedBy
        self.teamId = teamId
        self.priority = priority
        self.status = status
        self.type = type
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.location = location
    }
}

/// Aktivite Modeli
struct Activity: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var teamId: String
    var type: ActivityType
    var title: String
    var description: String
    var createdAt: Date
    var relatedTaskId: String?
    
    enum ActivityType: String, Codable {
        case taskCreated = "task_created"
        case taskCompleted = "task_completed"
        case teamJoined = "team_joined"
        case cleaningReported = "cleaning_reported"
        case issueReported = "issue_reported"
        case partnerRequestApproved = "partner_request_approved"
        
        var icon: String {
            switch self {
            case .taskCreated: return "plus.circle.fill"
            case .taskCompleted: return "checkmark.circle.fill"
            case .teamJoined: return "person.badge.plus.fill"
            case .cleaningReported: return "sparkles"
            case .issueReported: return "exclamationmark.triangle.fill"
            case .partnerRequestApproved: return "checkmark.seal.fill"
            }
        }
        
        var color: String {
            switch self {
            case .taskCreated: return "activityPurple"
            case .taskCompleted: return "successGreen"
            case .teamJoined: return "teamYellow"
            case .cleaningReported: return "feedbackOrange"
            case .issueReported: return "taskRed"
            case .partnerRequestApproved: return "successGreen"
            }
        }
    }
}

/// Temizlik Durumu Modeli
struct CleaningStatus: Codable, Identifiable {
    @DocumentID var id: String?
    var teamId: String
    var location: String
    var isClean: Bool
    var reportedBy: String             // User ID
    var reportedAt: Date
    var notes: String?
    
    init(
        id: String? = nil,
        teamId: String,
        location: String,
        isClean: Bool,
        reportedBy: String,
        reportedAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.teamId = teamId
        self.location = location
        self.isClean = isClean
        self.reportedBy = reportedBy
        self.reportedAt = reportedAt
        self.notes = notes
    }
}

/// İş Ortağı Talebi Modeli
struct PartnerRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var partnerId: String              // İş ortağı User ID
    var teamId: String                 // Hedef takım
    var serviceType: String            // Hizmet türü
    var description: String
    var status: RequestStatus
    var createdAt: Date
    var reviewedBy: String?            // Onaylayan/Reddeden User ID
    var reviewedAt: Date?
    var assignedTo: String?            // Otomatik atanan kullanıcı ID
    
    enum RequestStatus: String, Codable {
        case pending = "pending"
        case approved = "approved"
        case rejected = "rejected"
        
        var displayName: String {
            switch self {
            case .pending: return "Bekliyor"
            case .approved: return "Onaylandı"
            case .rejected: return "Reddedildi"
            }
        }
    }
    
    init(
        id: String? = nil,
        partnerId: String,
        teamId: String,
        serviceType: String,
        description: String,
        status: RequestStatus = .pending,
        createdAt: Date = Date(),
        reviewedBy: String? = nil,
        reviewedAt: Date? = nil,
        assignedTo: String? = nil
    ) {
        self.id = id
        self.partnerId = partnerId
        self.teamId = teamId
        self.serviceType = serviceType
        self.description = description
        self.status = status
        self.createdAt = createdAt
        self.reviewedBy = reviewedBy
        self.reviewedAt = reviewedAt
        self.assignedTo = assignedTo
    }
}
