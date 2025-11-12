import SwiftUI

struct SprintView: View {
    @EnvironmentObject private var exerciseViewModel: ExerciseViewModel
    @EnvironmentObject private var taskListViewModel: TaskListViewModel

    private var activeExercise: ExerciseType? { exerciseViewModel.currentExercise }
    private var pendingTasks: [TaskItem] {
        taskListViewModel.tasks.filter { !$0.isCompleted }
    }

    var body: some View {
        ZStack {
            Color("mainBack")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    timerView
                    exerciseDetails
                    controlButtons
                    pendingTasksSection
                }
                .padding(.horizontal)
                .padding(.top, 32)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Sprint Mode")
    }

    private var header: some View {
        VStack(spacing: 12) {
            if let task = exerciseViewModel.currentTask {
                Text(task.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            } else {
                Text("Start a sprint")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            Text(activeExercise?.name ?? "Pick a task to begin your workout")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var timerView: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.2), lineWidth: 16)
                .frame(width: 220, height: 220)

            if let exercise = activeExercise {
                let progress = progressValue(for: exercise)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AngularGradient(gradient: Gradient(colors: [Color("Color1"), Color("Color2")]), center: .center), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }

            VStack(spacing: 8) {
                Text(formattedTime)
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Text(labelForState)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var exerciseDetails: some View {
        VStack(spacing: 16) {
            ExerciseAnimationPlaceholder()
                .frame(height: 180)
            if let exercise = activeExercise {
                Text(exercise.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            switch exerciseViewModel.state {
            case .idle:
                startButton
            case .running:
                pauseButton
                finishButton
            case .paused:
                resumeButton
                finishButton
            case .finished:
                resetButton
            }
        }
        .animation(.default, value: exerciseViewModel.state)
    }

    private var startButton: some View {
        Menu {
            ForEach(pendingTasks) { task in
                Button(task.title) {
                    exerciseViewModel.startSprint(for: task)
                }
            }
        } label: {
            Label("Start", systemImage: "play.fill")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(pendingTasks.isEmpty ? Color.gray.opacity(0.2) : Color("Color1"))
                .foregroundColor(pendingTasks.isEmpty ? .secondary : .white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(pendingTasks.isEmpty)
    }

    private var pauseButton: some View {
        Button {
            exerciseViewModel.pause()
        } label: {
            Label("Pause", systemImage: "pause.fill")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("Color2").opacity(0.2))
                .foregroundColor(Color("Color2"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var resumeButton: some View {
        Button {
            exerciseViewModel.resume()
        } label: {
            Label("Resume", systemImage: "play.fill")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("Color1").opacity(0.15))
                .foregroundColor(Color("Color1"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var finishButton: some View {
        Button(role: .destructive) {
            exerciseViewModel.finish()
        } label: {
            Label("Finish", systemImage: "stop.fill")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("Color2").opacity(0.2))
                .foregroundColor(Color("Color2"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var resetButton: some View {
        Button {
            exerciseViewModel.reset()
        } label: {
            Label("New Sprint", systemImage: "arrow.clockwise")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("Color1").opacity(0.12))
                .foregroundColor(Color("Color1"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var pendingTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available tasks")
                    .font(.headline)
                Spacer()
                Text("\(pendingTasks.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(pendingTasks) { task in
                HStack {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.subheadline)
                        Text(task.exerciseType.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Start") {
                        exerciseViewModel.startSprint(for: task)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(12)
                .background(Color("Color2").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            if pendingTasks.isEmpty {
                Text("You're all caught up—great job!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color("Color2").opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func progressValue(for exercise: ExerciseType) -> CGFloat {
        guard exercise.exerciseDurationSafe > 0 else { return 0 }
        let total = CGFloat(exercise.exerciseDurationSafe)
        let remaining = CGFloat(exerciseViewModel.remainingSeconds)
        return 1 - (remaining / total)
    }

    private var formattedTime: String {
        let remaining = exerciseViewModel.remainingSeconds
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var labelForState: String {
        switch exerciseViewModel.state {
        case .idle:
            return "Ready to start"
        case .running:
            return "Keep moving"
        case .paused:
            return "Paused"
        case .finished:
            return "Sprint finished"
        }
    }
}

private struct ExerciseAnimationPlaceholder: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [Color("Color1").opacity(0.2), Color("Color2").opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: "figure.run")
                .font(.system(size: 96))
                .foregroundStyle(.primary)
                .opacity(animate ? 1 : 0.7)
                .scaleEffect(animate ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}

private extension ExerciseType {
    var exerciseDurationSafe: Int {
        max(duration, 1)
    }
}

#Preview {
    SprintView()
        .environmentObject(TaskListViewModel())
        .environmentObject(ExerciseViewModel(taskViewModel: TaskListViewModel()))
}
