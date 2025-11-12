import Foundation
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published private(set) var snapshot: TaskStatisticsSnapshot = .empty

    private let taskViewModel: TaskListViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(taskViewModel: TaskListViewModel) {
        self.taskViewModel = taskViewModel
        bind()
    }

    private func bind() {
        taskViewModel.$tasks
            .map { tasks in
                Self.makeSnapshot(from: tasks)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.snapshot = snapshot
            }
            .store(in: &cancellables)
    }

    private static func makeSnapshot(from tasks: [TaskItem]) -> TaskStatisticsSnapshot {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today

        let completedTasks = tasks.filter { $0.isCompleted }
        let completionDates: [(Date, TaskItem)] = completedTasks.compactMap { task in
            guard let completedAt = task.completedAt else { return nil }
            let day = calendar.startOfDay(for: completedAt)
            return (day, task)
        }

        let completedToday = completionDates.filter { calendar.isDate($0.0, inSameDayAs: today) }.count
        let completedThisWeek = completionDates.filter { $0.0 >= weekStart && $0.0 <= today }.count
        let totalWorkoutSeconds = completedTasks.reduce(0) { $0 + $1.exerciseType.duration }

        var dailyCounts: [Date: Int] = [:]
        for offset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                dailyCounts[date] = 0
            }
        }

        for (date, _) in completionDates {
            if date >= weekStart && date <= today {
                dailyCounts[date, default: 0] += 1
            }
        }

        let weeklyCompletions = dailyCounts
            .sorted { $0.key < $1.key }
            .map { TaskStatisticsSnapshot.DailyCompletion(date: $0.key, count: $0.value) }

        return TaskStatisticsSnapshot(
            date: now,
            completedToday: completedToday,
            completedThisWeek: completedThisWeek,
            totalWorkoutSeconds: totalWorkoutSeconds,
            weeklyCompletions: weeklyCompletions
        )
    }
}
