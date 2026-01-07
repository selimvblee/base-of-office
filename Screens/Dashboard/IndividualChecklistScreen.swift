import SwiftUI

/// Bireysel Panel - Kullanıcının kişisel checklist alanı
struct IndividualChecklistScreen: View {
    @StateObject private var taskService = TaskService()
    @StateObject private var authService = AuthService()
    
    @State private var newTaskTitle = ""
    @State private var filter: ChecklistFilter = .all
    
    enum ChecklistFilter {
        case all, completed, pending
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Üst Başlık
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Yapılacaklar")
                            .font(AppTypography.title1(weight: AppTypography.bold))
                        Text("Kişisel sorumluluk alanın ve günlük listen.")
                            .font(AppTypography.caption1())
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Yeni Görev Ekleme
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            BrutalistTextField(
                                placeholder: "Yeni bir görev ekle...",
                                text: $newTaskTitle
                            )
                            
                            Button(action: addNewTask) {
                                Image(systemName: "plus")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 54, height: 54)
                                    .background(AppColors.taskRed)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.border, lineWidth: 2))
                                    .cornerRadius(8)
                                    .mediumBrutalistShadow()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Filtreleme
                    HStack(spacing: 10) {
                        filterButton(title: "Hepsi", type: .all)
                        filterButton(title: "Yapılacak", type: .pending)
                        filterButton(title: "Tamamlanan", type: .completed)
                    }
                    .padding(.horizontal, 24)
                    
                    // Liste
                    ScrollView {
                        VStack(spacing: 16) {
                            if filteredTasks.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(filteredTasks) { task in
                                    ChecklistItemCard(task: task) {
                                        toggleTask(task)
                                    }
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textLight)
            Text("Burada henüz bir şey yok.")
                .font(AppTypography.headline(weight: AppTypography.semiBold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.top, 100)
    }
    
    private func filterButton(title: String, type: ChecklistFilter) -> some View {
        Button(action: { filter = type }) {
            Text(title)
                .font(AppTypography.caption1(weight: AppTypography.bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(filter == type ? AppColors.teamYellow : .white)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppColors.border, lineWidth: 2))
                .cornerRadius(6)
                .foregroundColor(AppColors.textPrimary)
        }
    }
    
    // MARK: - Logic
    
    private var filteredTasks: [Task] {
        switch filter {
        case .all: return taskService.myTasks
        case .completed: return taskService.myTasks.filter { $0.status == .completed }
        case .pending: return taskService.myTasks.filter { $0.status != .completed }
        }
    }
    
    private func addNewTask() {
        guard !newTaskTitle.isEmpty, let user = authService.currentUser else { return }
        // Local state update for demo or use service
        newTaskTitle = ""
    }
    
    private func toggleTask(_ task: Task) {
        // Task status update logic
    }
}

struct ChecklistItemCard: View {
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        BrutalistCard(backgroundColor: task.status == .completed ? AppColors.backgroundSecondary : .white) {
            HStack(spacing: 16) {
                Button(action: onToggle) {
                    Image(systemName: task.status == .completed ? "checkmark.square.fill" : "square")
                        .font(.title2.bold())
                        .foregroundColor(task.status == .completed ? AppColors.successGreen : AppColors.border)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(AppTypography.headline(weight: AppTypography.bold))
                        .strikethrough(task.status == .completed)
                        .foregroundColor(task.status == .completed ? AppColors.textLight : AppColors.textPrimary)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(AppTypography.caption2())
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if task.priority == .critical {
                    Circle()
                        .fill(AppColors.taskRed)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    IndividualChecklistScreen()
}
