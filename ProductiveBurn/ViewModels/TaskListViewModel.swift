import Foundation
import Combine
import SwiftUI

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var availableExercises: [ExerciseType] = ExerciseType.defaultExercises

    private let persistenceService: TaskPersistenceService
    private var cancellables: Set<AnyCancellable> = []

    init(persistenceService: TaskPersistenceService) {
        self.persistenceService = persistenceService
        loadTasks()
        observeChanges()
    }

    convenience init() {
        self.init(persistenceService: UserDefaultsTaskPersistenceService())
    }

    func addTask(title: String, exercise: ExerciseType, dueDate: Date?, customDuration: Int?) {
        objectWillChange.send()
        var exerciseCopy = exercise
        if let customDuration {
            exerciseCopy.duration = max(customDuration, 1)
        }
        let newTask = TaskItem(title: title, exerciseType: exerciseCopy, dueDate: dueDate)
        tasks.append(newTask)
    }

    func updateTask(_ task: TaskItem, title: String, exercise: ExerciseType, dueDate: Date?, customDuration: Int?) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        objectWillChange.send()
        var updated = tasks[index]
        updated.title = title
        var exerciseCopy = exercise
        if let customDuration {
            exerciseCopy.duration = max(customDuration, 1)
        }
        updated.exerciseType = exerciseCopy
        updated.dueDate = dueDate
        tasks[index] = updated
    }

    @discardableResult
    func toggleCompletion(for task: TaskItem) -> TaskItem? {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return nil }
        objectWillChange.send()
        var updated = tasks[index]
        updated.isCompleted.toggle()
        updated.completedAt = updated.isCompleted ? Date() : nil
        tasks[index] = updated
        return updated
    }

    func deleteTask(at offsets: IndexSet) {
        objectWillChange.send()
        tasks.remove(atOffsets: offsets)
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        objectWillChange.send()
        tasks.move(fromOffsets: source, toOffset: destination)
    }

    func resetAllTasks() {
        objectWillChange.send()
        tasks.removeAll()
    }

    func taskBinding(for task: TaskItem) -> Binding<TaskItem> {
        Binding(
            get: { task },
            set: { [weak self] updated in
                guard let self else { return }
                self.updateTask(updated, title: updated.title, exercise: updated.exerciseType, dueDate: updated.dueDate, customDuration: updated.exerciseType.duration)
            }
        )
    }

    private func loadTasks() {
        tasks = persistenceService.loadTasks()
    }

    private func observeChanges() {
        $tasks
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] items in
                self?.persistenceService.saveTasks(items)
            }
            .store(in: &cancellables)
    }
}
