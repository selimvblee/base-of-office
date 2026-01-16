import Foundation
import FirebaseFirestore

enum TaskPriority: String, Codable {
    case low, medium, high, critical
}

enum TaskStatus: String, Codable {
    case pending, inProgress, completed, cancelled
}

enum TaskType: String, Codable {
    case regular, cleaning, issue, partnerRequest
}

struct OfficeTask: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String?
    var description: String?
    var assignedTo: String?
    var assignedBy: String?
    var teamId: String?
    var priority: TaskPriority?
    var status: TaskStatus?
    var type: TaskType? = .regular
    var dueDate: Date?
    @ServerTimestamp var createdAt: Date?
    var completedAt: Date?
}
