import Foundation
import FirebaseFirestore

struct Team: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String?
    var inviteCode: String?
    var founderId: String?
    var memberIds: [String]?
    var members: [User]? = []
}
