import SwiftUI
import Combine

// MARK: - Mock TeamService
class TeamService: ObservableObject {
    @Published var currentTeam: Team?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = TeamService()
    
    func createTeam(name: String, founderId: String) async -> Team? {
        await MainActor.run { isLoading = true }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let inviteCode = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        let newTeam = Team(
            id: UUID().uuidString,
            name: name,
            inviteCode: inviteCode,
            founderId: founderId,
            memberIds: [founderId]
        )
        
        await MainActor.run {
            self.currentTeam = newTeam
            self.isLoading = false
            // AuthService kullanıcı bilgilerini güncelle
            if var user = AuthService.shared.currentUser {
                user.role = .founder
                user.teamId = newTeam.id
                AuthService.shared.currentUser = user
            }
        }
        
        return newTeam
    }
    
    func joinTeam(code: String, userId: String) async -> Bool {
        await MainActor.run { 
            isLoading = true 
            errorMessage = nil
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if code.uppercased() == "OFFICE" || code.count == 6 {
            await MainActor.run {
                self.currentTeam = Team(
                    id: "mock-team-id",
                    name: "Demo Panel",
                    inviteCode: code.uppercased(),
                    founderId: "founder-id",
                    memberIds: ["founder-id", userId]
                )
                self.isLoading = false
                // AuthService kullanıcı bilgilerini güncelle
                if var user = AuthService.shared.currentUser {
                    user.role = .user
                    user.teamId = "mock-team-id"
                    AuthService.shared.currentUser = user
                }
            }
            return true
        } else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Geçersiz davet kodu! Lütfen 'OFFICE' kodunu deneyin."
            }
            return false
        }
    }
}

// MARK: - Mock TaskService
class TaskService: ObservableObject {
    static let shared = TaskService()
    
    @Published var myTasks: [OfficeTask] = []
    @Published var teamTasks: [OfficeTask] = []
    
    init() {
        myTasks = [
            OfficeTask(id: "1", title: "Proje sunumu hazırla", description: "Q4 raporları için", assignedTo: "demo-user", assignedBy: "manager", teamId: "team1", priority: .high, status: .pending),
            OfficeTask(id: "2", title: "E-postaları kontrol et", description: "Müşteri geri bildirimleri", assignedTo: "demo-user", assignedBy: "manager", teamId: "team1", priority: .medium, status: .pending)
        ]
    }
}
