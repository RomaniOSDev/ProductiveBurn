import Foundation

struct TaskItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var exerciseType: ExerciseType
    var dueDate: Date?
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        exerciseType: ExerciseType,
        dueDate: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.exerciseType = exerciseType
        self.dueDate = dueDate
        self.completedAt = completedAt
    }
}

extension TaskItem {
    static let preview = TaskItem(title: "Write report", exerciseType: .preview)
}
