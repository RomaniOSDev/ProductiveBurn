import Foundation

struct ExerciseType: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var duration: Int
    var description: String

    init(id: UUID = UUID(), name: String, duration: Int, description: String) {
        self.id = id
        self.name = name
        self.duration = duration
        self.description = description
    }
}

extension ExerciseType {
    static let defaultExercises: [ExerciseType] = [
        ExerciseType(name: "Squats", duration: 60, description: "20 squats"),
        ExerciseType(name: "Burpees", duration: 45, description: "10 burpees"),
        ExerciseType(name: "Plank", duration: 30, description: "Hold plank for 30 seconds"),
        ExerciseType(name: "Push-ups", duration: 60, description: "15 push-ups"),
        ExerciseType(name: "Jog in Place", duration: 120, description: "Jog in place for 2 minutes")
    ]

    static let preview: ExerciseType = ExerciseType(name: "Squats", duration: 60, description: "20 squats")
}
