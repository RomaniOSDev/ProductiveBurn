import Foundation

protocol TaskPersistenceService {
    func loadTasks() -> [TaskItem]
    func saveTasks(_ tasks: [TaskItem])
}

final class UserDefaultsTaskPersistenceService: TaskPersistenceService {
    private let storageKey = "fitness_sprints_tasks"
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadTasks() -> [TaskItem] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        do {
            return try decoder.decode([TaskItem].self, from: data)
        } catch {
            print("Failed to decode tasks: \(error)")
            return []
        }
    }

    func saveTasks(_ tasks: [TaskItem]) {
        do {
            let data = try encoder.encode(tasks)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode tasks: \(error)")
        }
    }
}
