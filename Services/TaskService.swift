import Foundation
import FirebaseFirestore

/// Task Management Service
class TaskService: ObservableObject {
    @Published var myTasks: [Task] = []
    @Published var teamTasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = FirebaseConfig.shared.db
    
    /// Görev oluştur
    func createTask(
        title: String,
        description: String,
        assignedTo: String,
        assignedBy: String,
        teamId: String,
        priority: Task.TaskPriority = .medium,
        type: Task.TaskType = .regular,
        dueDate: Date? = nil,
        location: String? = nil
    ) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let task = Task(
                title: title,
                description: description,
                assignedTo: assignedTo,
                assignedBy: assignedBy,
                teamId: teamId,
                priority: priority,
                type: type,
                dueDate: dueDate,
                location: location
            )
            
            try db.collection(FirestoreCollections.tasks)
                .addDocument(from: task)
            
            // Aktivite oluştur
            let activity = Activity(
                userId: assignedBy,
                teamId: teamId,
                type: .taskCreated,
                title: "Yeni Görev Oluşturuldu",
                description: "\(title) görevi oluşturuldu",
                relatedTaskId: task.id
            )
            
            try db.collection(FirestoreCollections.activities)
                .addDocument(from: activity)
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print("✅ Task created successfully: \(title)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Kullanıcının görevlerini getir
    func fetchMyTasks(userId: String) async throws {
        isLoading = true
        
        do {
            let snapshot = try await db.collection(FirestoreCollections.tasks)
                .whereField("assignedTo", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let tasks = try snapshot.documents.compactMap { doc in
                try doc.data(as: Task.self)
            }
            
            DispatchQueue.main.async {
                self.myTasks = tasks
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Takım görevlerini getir
    func fetchTeamTasks(teamId: String) async throws {
        isLoading = true
        
        do {
            let snapshot = try await db.collection(FirestoreCollections.tasks)
                .whereField("teamId", isEqualTo: teamId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let tasks = try snapshot.documents.compactMap { doc in
                try doc.data(as: Task.self)
            }
            
            DispatchQueue.main.async {
                self.teamTasks = tasks
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Görev durumunu güncelle
    func updateTaskStatus(taskId: String, status: Task.TaskStatus) async throws {
        do {
            try await db.collection(FirestoreCollections.tasks)
                .document(taskId)
                .updateData([
                    "status": status.rawValue,
                    "completedAt": status == .completed ? Date() : FieldValue.delete()
                ])
            
            print("✅ Task status updated: \(status.displayName)")
        } catch {
            throw error
        }
    }
    
    /// Temizlik durumu bildir
    func reportCleaningStatus(
        teamId: String,
        location: String,
        isClean: Bool,
        reportedBy: String,
        notes: String? = nil
    ) async throws {
        do {
            let status = CleaningStatus(
                teamId: teamId,
                location: location,
                isClean: isClean,
                reportedBy: reportedBy,
                notes: notes
            )
            
            try db.collection(FirestoreCollections.cleaningStatus)
                .addDocument(from: status)
            
            // Aktivite oluştur
            let activity = Activity(
                userId: reportedBy,
                teamId: teamId,
                type: .cleaningReported,
                title: "Temizlik Durumu Bildirildi",
                description: "\(location) - \(isClean ? "Temiz" : "Kirli")"
            )
            
            try db.collection(FirestoreCollections.activities)
                .addDocument(from: activity)
            
            print("✅ Cleaning status reported: \(location) - \(isClean ? "Clean" : "Dirty")")
        } catch {
            throw error
        }
    }
    
    /// Temizlik durumlarını getir
    func fetchCleaningStatuses(teamId: String) async throws -> [CleaningStatus] {
        do {
            let snapshot = try await db.collection(FirestoreCollections.cleaningStatus)
                .whereField("teamId", isEqualTo: teamId)
                .order(by: "reportedAt", descending: true)
                .limit(to: 10)
                .getDocuments()
            
            return try snapshot.documents.compactMap { doc in
                try doc.data(as: CleaningStatus.self)
            }
    /// İş ortağı talebini incele (Onayla/Reddet)
    /// Onaylanırsa otomatik olarak bir görev oluşturur
    func reviewPartnerRequest(
        request: PartnerRequest,
        status: PartnerRequest.RequestStatus,
        reviewerId: String,
        assignToMemberId: String? = nil
    ) async throws {
        guard let requestId = request.id else { return }
        
        do {
            // Talebi güncelle
            try await db.collection(FirestoreCollections.partnerRequests)
                .document(requestId)
                .updateData([
                    "status": status.rawValue,
                    "reviewedBy": reviewerId,
                    "reviewedAt": Date(),
                    "assignedTo": assignToMemberId as Any
                ])
            
            // Eğer onaylandıysa OTOMATİK GÖREV OLUŞTUR
            if status == .approved, let memberId = assignToMemberId {
                try await createTask(
                    title: "İş Ortağı: \(request.serviceType)",
                    description: request.description,
                    assignedTo: memberId,
                    assignedBy: reviewerId,
                    teamId: request.teamId,
                    priority: .high,
                    type: .partnerRequest
                )
                
                // Aktivite oluştur
                let activity = Activity(
                    userId: reviewerId,
                    teamId: request.teamId,
                    type: .partnerRequestApproved,
                    title: "Hizmet Talebi Onaylandı",
                    description: "\(request.serviceType) için görev atandı."
                )
                
                try db.collection(FirestoreCollections.activities)
                    .addDocument(from: activity)
            }
            
            print("✅ Partner request reviewed: \(status.displayName)")
        } catch {
            throw error
        }
    }
}
