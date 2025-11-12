import Foundation
import Combine

@MainActor
final class ExerciseViewModel: ObservableObject {
    enum SprintState {
        case idle
        case running
        case paused
        case finished
    }

    @Published private(set) var currentTask: TaskItem?
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var state: SprintState = .idle

    var currentExercise: ExerciseType? {
        currentTask?.exerciseType
    }

    private var timerCancellable: AnyCancellable?
    private let taskViewModel: TaskListViewModel

    init(taskViewModel: TaskListViewModel) {
        self.taskViewModel = taskViewModel
    }

    func startSprint(for task: TaskItem) {
        let referenceTask = taskViewModel.tasks.first(where: { $0.id == task.id }) ?? task
        currentTask = referenceTask
        remainingSeconds = referenceTask.exerciseType.duration
        state = .running
        startTimer()
    }

    func pause() {
        guard state == .running else { return }
        timerCancellable?.cancel()
        timerCancellable = nil
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        startTimer()
    }

    func finish() {
        timerCancellable?.cancel()
        timerCancellable = nil
        remainingSeconds = 0
        state = .finished
    }

    func reset() {
        timerCancellable?.cancel()
        timerCancellable = nil
        state = .idle
        remainingSeconds = 0
        currentTask = nil
    }

    private func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard self.remainingSeconds > 0 else {
                    self.finish()
                    return
                }
                self.remainingSeconds -= 1
                if self.remainingSeconds == 0 {
                    self.finish()
                }
            }
    }
}
