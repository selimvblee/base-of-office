import SwiftUI
import Combine

/// Bireysel Panel - Kişisel Verimlilik Merkezi
struct IndividualChecklistScreen: View {
    @Binding var selectedTab: Int
    @StateObject private var authService = AuthService.shared
    @StateObject private var taskService = TaskService()
    
    // Mood Tracker
    @State private var selectedMood: Mood? = nil
    
    // Daily Note
    @State private var dailyNote: String = ""
    @State private var isNoteExpanded: Bool = false
    
    // Tasks
    @State private var newTaskTitle = ""
    @State private var filter: ChecklistFilter = .all
    
    // Goals
    @State private var weeklyGoals: [Goal] = Goal.sampleWeeklyGoals
    @State private var monthlyGoals: [Goal] = Goal.sampleMonthlyGoals
    @State private var selectedGoalTab: GoalTab = .weekly
    
    enum ChecklistFilter: CaseIterable {
        case all, pending, completed
        
        var title: String {
            switch self {
            case .all: return "Hepsi"
            case .pending: return "Yapılacak"
            case .completed: return "Tamamlanan"
            }
        }
    }
    
    enum GoalTab: CaseIterable {
        case weekly, monthly
        
        var title: String {
            switch self {
            case .weekly: return "Haftalık"
            case .monthly: return "Aylık"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        moodTrackerSection
                        dailyNoteSection
                        quickStatsRow
                        dailyTasksSection
                        goalsSection
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(currentDayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(currentDateString)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Circle()
                .fill(AppColors.primary)
                .frame(width: 44, height: 44)
                .overlay(Text(String(authService.currentUser?.username?.prefix(1) ?? authService.currentUser?.fullName?.prefix(1) ?? "B")).font(.system(size: 18, weight: .bold)).foregroundColor(.white))
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .background(
                    Circle()
                        .fill(Color.black)
                        .offset(x: 2, y: 2)
                )
                .padding(.trailing, 2)
                .padding(.bottom, 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Mood Tracker Section
    
    private var moodTrackerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugün nasıl hissediyorsun?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    moodButton(mood: mood)
                }
            }
        }
        .padding(16)
        .background(AppColors.background)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .background(
            Rectangle()
                .fill(Color.black)
                .offset(x: 2, y: 2)
        )
        .padding(.trailing, 2)
        .padding(.bottom, 2)
        .padding(.horizontal, 20)
    }
    
    private func moodButton(mood: Mood) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMood = mood
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                
                Text(mood.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(selectedMood == mood ? .white : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selectedMood == mood ? mood.color : AppColors.background)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Daily Note Section
    
    private var dailyNoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isNoteExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "pencil.and.list.clipboard")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("Bugüne bir not bırak")
                        .font(.system(size: 16, weight: .bold))
                    
                    Spacer()
                    
                    Image(systemName: isNoteExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(AppColors.textPrimary)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isNoteExpanded {
                TextEditor(text: $dailyNote)
                    .font(.system(size: 14))
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(Color.white)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                    .scrollContentBackground(.hidden)
            }
        }
        .padding(16)
        .background(AppColors.background)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .background(
            Rectangle()
                .fill(Color.black)
                .offset(x: 2, y: 2)
        )
        .padding(.trailing, 2)
        .padding(.bottom, 2)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Quick Stats Row
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            miniStatCard(title: "Toplam", value: "\(taskService.myTasks.count)", icon: "list.bullet.circle.fill", color: AppColors.activityPurple)
            miniStatCard(title: "Yapılacak", value: "\(taskService.myTasks.filter { $0.status != .completed }.count)", icon: "clock.fill", color: AppColors.feedbackOrange)
            miniStatCard(title: "Tamamlanan", value: "\(taskService.myTasks.filter { $0.status == .completed }.count)", icon: "checkmark.circle.fill", color: AppColors.success)
        }
        .padding(.horizontal, 20)
    }
    
    private func miniStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .brutalistCard(color: color, shadow: 2)
    }
    
    // MARK: - Daily Tasks Section
    
    private var dailyTasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Günlük Görevlerin")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 20)
            
            // Add Task
            HStack(spacing: 12) {
                TextField("Yeni bir görev ekle...", text: $newTaskTitle)
                    .font(.system(size: 14))
                    .padding(14)
                    .background(AppColors.background)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                    .background(
                        Rectangle()
                            .fill(Color.black)
                            .offset(x: 2, y: 2)
                    )
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
                    .onSubmit { addNewTask() }
                
                Button(action: addNewTask) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                }
                .buttonStyle(PlainButtonStyle())
                .brutalistButton(color: newTaskTitle.isEmpty ? AppColors.textTertiary : AppColors.primary, radius: 0)
                .disabled(newTaskTitle.isEmpty)
            }
            .padding(.horizontal, 20)
            
            // Filter
            HStack(spacing: 10) {
                ForEach(ChecklistFilter.allCases, id: \.self) { filterType in
                    filterButton(filter: filterType)
                }
            }
            .padding(.horizontal, 20)
            
            // Task List
            VStack(spacing: 12) {
                if filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredTasks) { task in
                        taskCard(task: task)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func filterButton(filter filterType: ChecklistFilter) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                filter = filterType
            }
        }) {
            Text(filterType.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(filter == filterType ? .white : AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(filter == filterType ? AppColors.primary : AppColors.background)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                .background(
                    Rectangle()
                        .fill(Color.black)
                        .offset(x: 1, y: 1)
                )
                .padding(.trailing, 1)
                .padding(.bottom, 1)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(AppColors.textTertiary)
            
            Text(emptyStateMessage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .all: return "Henüz görev yok"
        case .pending: return "Yapılacak görev yok"
        case .completed: return "Tamamlanan görev yok"
        }
    }
    
    private func taskCard(task: OfficeTask) -> some View {
        HStack(spacing: 14) {
            Button(action: { toggleTask(task) }) {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(task.status == .completed ? AppColors.success : AppColors.border)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "İsimsiz Görev")
                    .font(.system(size: 15, weight: .semibold))
                    .strikethrough(task.status == .completed)
                    .foregroundColor(task.status == .completed ? AppColors.textSecondary : AppColors.textPrimary)
            }
            
            Spacer()
            
            Button(action: { deleteTask(task) }) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.taskRed)
            }
        }
        .padding(16)
        .brutalistCard(color: AppColors.background, shadow: 2)
    }
    
    // MARK: - Goals Section
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hedeflerin")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 20)
            
            // Goal Tabs
            HStack(spacing: 10) {
                ForEach(GoalTab.allCases, id: \.self) { tab in
                    goalTabButton(tab: tab)
                }
            }
            .padding(.horizontal, 20)
            
            // Goal List
            VStack(spacing: 12) {
                let goals = selectedGoalTab == .weekly ? weeklyGoals : monthlyGoals
                
                if goals.isEmpty {
                    Text("Henüz hedef eklenmemiş")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else {
                    ForEach(goals) { goal in
                        goalCard(goal: goal)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func goalTabButton(tab: GoalTab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedGoalTab = tab
            }
        }) {
            Text(tab.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(selectedGoalTab == tab ? .white : AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedGoalTab == tab ? Color.neoPurple : AppColors.background)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                .background(
                    Rectangle()
                        .fill(Color.black)
                        .offset(x: 1, y: 1)
                )
                .padding(.trailing, 1)
                .padding(.bottom, 1)
        }
    }
    
    private func goalCard(goal: Goal) -> some View {
        HStack(spacing: 14) {
            Button(action: { toggleGoal(goal) }) {
                Image(systemName: goal.isCompleted ? "flag.fill" : "flag")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(goal.isCompleted ? Color.neoPurple : AppColors.border)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.system(size: 15, weight: .semibold))
                    .strikethrough(goal.isCompleted)
                    .foregroundColor(goal.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(AppColors.border.opacity(0.3))
                            .frame(height: 6)
                        
                        Rectangle()
                            .fill(goal.isCompleted ? AppColors.success : Color.neoPurple)
                            .frame(width: geometry.size.width * goal.progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            Text("\(Int(goal.progress * 100))%")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(16)
        .background(AppColors.background)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .background(
            Rectangle()
                .fill(Color.black)
                .offset(x: 2, y: 2)
        )
        .padding(.trailing, 2)
        .padding(.bottom, 2)
    }
    
    // MARK: - Actions
    
    private func addNewTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newTask = OfficeTask(
            id: UUID().uuidString,
            title: newTaskTitle.trimmingCharacters(in: .whitespaces),
            description: "",
            assignedTo: "demo-user",
            assignedBy: "demo-user",
            teamId: "team1",
            priority: .medium,
            status: .pending,
            dueDate: Date().addingTimeInterval(86400)
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            taskService.myTasks.insert(newTask, at: 0)
        }
        
        newTaskTitle = ""
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func toggleTask(_ task: OfficeTask) {
        guard let index = taskService.myTasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if taskService.myTasks[index].status == .completed {
                taskService.myTasks[index].status = .pending
                taskService.myTasks[index].completedAt = nil
            } else {
                taskService.myTasks[index].status = .completed
                taskService.myTasks[index].completedAt = Date()
            }
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func deleteTask(_ task: OfficeTask) {
        withAnimation(.easeInOut(duration: 0.3)) {
            taskService.myTasks.removeAll { $0.id == task.id }
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    private func toggleGoal(_ goal: Goal) {
        if selectedGoalTab == .weekly {
            if let index = weeklyGoals.firstIndex(where: { $0.id == goal.id }) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    weeklyGoals[index].isCompleted.toggle()
                    weeklyGoals[index].progress = weeklyGoals[index].isCompleted ? 1.0 : 0.5
                }
            }
        } else {
            if let index = monthlyGoals.firstIndex(where: { $0.id == goal.id }) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    monthlyGoals[index].isCompleted.toggle()
                    monthlyGoals[index].progress = monthlyGoals[index].isCompleted ? 1.0 : 0.5
                }
            }
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private var filteredTasks: [OfficeTask] {
        switch filter {
        case .all: return taskService.myTasks
        case .completed: return taskService.myTasks.filter { $0.status == .completed }
        case .pending: return taskService.myTasks.filter { $0.status != .completed }
        }
    }
    
    private var currentDayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).capitalized
    }
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Supporting Types

enum Mood: String, CaseIterable {
    case great, good, neutral, bad, terrible
    
    var emoji: String {
        switch self {
        case .great: return "🤩"
        case .good: return "😊"
        case .neutral: return "😐"
        case .bad: return "😔"
        case .terrible: return "😤"
        }
    }
    
    var title: String {
        switch self {
        case .great: return "Harika"
        case .good: return "İyi"
        case .neutral: return "Normal"
        case .bad: return "Kötü"
        case .terrible: return "Berbat"
        }
    }
    
    var color: Color {
        switch self {
        case .great: return Color.neoPurple
        case .good: return AppColors.success
        case .neutral: return AppColors.feedbackOrange
        case .bad: return AppColors.textSecondary
        case .terrible: return Color.neoRed
        }
    }
}

struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var progress: Double
    var isCompleted: Bool
    
    static var sampleWeeklyGoals: [Goal] = [
        Goal(title: "3 toplantı organize et", progress: 0.66, isCompleted: false),
        Goal(title: "Haftalık raporu tamamla", progress: 0.5, isCompleted: false),
        Goal(title: "Yeni özellik testi", progress: 1.0, isCompleted: true)
    ]
    
    static var sampleMonthlyGoals: [Goal] = [
        Goal(title: "10 müşteri görüşmesi", progress: 0.7, isCompleted: false),
        Goal(title: "Proje sunumu hazırla", progress: 0.3, isCompleted: false),
        Goal(title: "Eğitim modüllerini tamamla", progress: 0.9, isCompleted: false)
    ]
}

#Preview {
    IndividualChecklistScreen(selectedTab: .constant(0))
}
