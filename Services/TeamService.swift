import Foundation
import FirebaseFirestore

/// Team Management Service
class TeamService: ObservableObject {
    @Published var currentTeam: Team?
    @Published var teamMembers: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = FirebaseConfig.shared.db
    
    /// Takım oluştur ve davet kodu üret
    func createTeam(
        name: String,
        description: String,
        founderId: String,
        occupations: [String]
    ) async throws -> Team {
        isLoading = true
        errorMessage = nil
        
        do {
            // 6 karakterlik benzersiz davet kodu üret
            let inviteCode = generateInviteCode()
            
            let team = Team(
                name: name,
                description: description,
                founderId: founderId,
                inviteCode: inviteCode,
                members: [founderId],
                occupations: occupations
            )
            
            let docRef = try db.collection(FirestoreCollections.teams)
                .addDocument(from: team)
            
            // Kullanıcının teamId'sini güncelle
            try await db.collection(FirestoreCollections.users)
                .document(founderId)
                .updateData(["teamId": docRef.documentID])
            
            var createdTeam = team
            createdTeam.id = docRef.documentID
            
            DispatchQueue.main.async {
                self.currentTeam = createdTeam
                self.isLoading = false
            }
            
            print("✅ Team created successfully: \(name) with code: \(inviteCode)")
            return createdTeam
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Davet koduyla takıma katıl
    func joinTeamWithCode(inviteCode: String, userId: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Davet koduna sahip takımı bul
            let snapshot = try await db.collection(FirestoreCollections.teams)
                .whereField("inviteCode", isEqualTo: inviteCode.uppercased())
                .getDocuments()
            
            guard let teamDoc = snapshot.documents.first else {
                throw NSError(domain: "", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "Geçersiz davet kodu"
                ])
            }
            
            let teamId = teamDoc.documentID
            
            // Takıma üye ekle
            try await db.collection(FirestoreCollections.teams)
                .document(teamId)
                .updateData([
                    "members": FieldValue.arrayUnion([userId])
                ])
            
            // Kullanıcının teamId'sini güncelle
            try await db.collection(FirestoreCollections.users)
                .document(userId)
                .updateData(["teamId": teamId])
            
            // Takım verisini çek
            try await fetchTeam(teamId: teamId)
            
            print("✅ User joined team successfully with code: \(inviteCode)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Takım bilgilerini getir
    func fetchTeam(teamId: String) async throws {
        isLoading = true
        
        do {
            let snapshot = try await db.collection(FirestoreCollections.teams)
                .document(teamId)
                .getDocument()
            
            let team = try snapshot.data(as: Team.self)
            
            DispatchQueue.main.async {
                self.currentTeam = team
                self.isLoading = false
            }
            
            // Takım üyelerini getir
            try await fetchTeamMembers(memberIds: team.members)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Takım üyelerini getir
    private func fetchTeamMembers(memberIds: [String]) async throws {
        guard !memberIds.isEmpty else { return }
        
        do {
            var members: [User] = []
            
            for memberId in memberIds {
                let snapshot = try await db.collection(FirestoreCollections.users)
                    .document(memberId)
                    .getDocument()
                
                if let user = try? snapshot.data(as: User.self) {
                    members.append(user)
                }
            }
            
            DispatchQueue.main.async {
                self.teamMembers = members
            }
        } catch {
            print("❌ Error fetching team members: \(error.localizedDescription)")
        }
    }
    
    /// 6 karakterlik benzersiz davet kodu üret (BAW4H3 formatında)
    private func generateInviteCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}
