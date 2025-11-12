import SwiftUI

struct MainTasksView: View {
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @EnvironmentObject private var exerciseViewModel: ExerciseViewModel
    @AppStorage("autoStartSprint") private var autoStartSprint: Bool = true

    @State private var isPresentingAddTask = false
    @State private var taskToEdit: TaskItem?

    var body: some View {
        ZStack {
            Color("mainBack")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if taskListViewModel.tasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
        }
        .navigationTitle("Fitness Sprints")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { taskToEdit = nil; isPresentingAddTask = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add task")
            }
        }
        .sheet(isPresented: $isPresentingAddTask) {
            AddTaskView(
                task: taskToEdit,
                exercises: taskListViewModel.availableExercises,
                onSave: { title, exercise, dueDate, customDuration in
                    if let taskToEdit {
                        taskListViewModel.updateTask(taskToEdit, title: title, exercise: exercise, dueDate: dueDate, customDuration: customDuration)
                    } else {
                        taskListViewModel.addTask(title: title, exercise: exercise, dueDate: dueDate, customDuration: customDuration)
                    }
                    self.taskToEdit = nil
                },
                onDelete: {
                    if let taskToEdit,
                       let index = taskListViewModel.tasks.firstIndex(of: taskToEdit) {
                        taskListViewModel.deleteTask(at: IndexSet(integer: index))
                    }
                    self.taskToEdit = nil
                }
            )
        }
    }

    private var taskList: some View {
        List {
            ForEach(taskListViewModel.tasks) { task in
                TaskRowView(task: task, onToggle: handleToggleCompletion, onEdit: { taskToEdit = task; isPresentingAddTask = true })
            }
            .onDelete(perform: taskListViewModel.deleteTask)
            .onMove(perform: taskListViewModel.moveTask)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color("mainBack"))
        .toolbar {
            EditButton()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color("Color2"))
            Text("Add your first task")
                .font(.title3)
                .foregroundStyle(.secondary)
            Button("Create Task") {
                isPresentingAddTask = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func handleToggleCompletion(_ task: TaskItem) {
        guard let updatedTask = taskListViewModel.toggleCompletion(for: task) else { return }
        if updatedTask.isCompleted && autoStartSprint {
            exerciseViewModel.startSprint(for: updatedTask)
        } else if exerciseViewModel.currentTask?.id == updatedTask.id {
            exerciseViewModel.reset()
        }
    }
}

private struct TaskRowView: View {
    let task: TaskItem
    let onToggle: (TaskItem) -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { onToggle(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? Color("Color1") : Color.secondary)
                    .font(.system(size: 24))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted, color: .secondary)
                Text(task.exerciseType.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        MainTasksView()
            .environmentObject(TaskListViewModel())
            .environmentObject(ExerciseViewModel(taskViewModel: TaskListViewModel()))
    }
}
