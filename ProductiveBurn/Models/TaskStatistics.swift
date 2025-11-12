import Foundation

struct TaskStatisticsSnapshot: Equatable {
    let date: Date
    let completedToday: Int
    let completedThisWeek: Int
    let totalWorkoutSeconds: Int
    let weeklyCompletions: [DailyCompletion]

    struct DailyCompletion: Identifiable, Equatable {
        let id = UUID()
        let date: Date
        let count: Int
    }

    static let empty = TaskStatisticsSnapshot(
        date: Date(),
        completedToday: 0,
        completedThisWeek: 0,
        totalWorkoutSeconds: 0,
        weeklyCompletions: []
    )
}
