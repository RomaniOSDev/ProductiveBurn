import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss

    let task: TaskItem?
    let exercises: [ExerciseType]
    var onSave: (String, ExerciseType, Date?, Int?) -> Void
    var onDelete: (() -> Void)?

    @State private var title: String = ""
    @State private var selectedExercise: ExerciseType
    @State private var dueDate: Date = Date()
    @State private var hasDueDate = false
    @State private var customDuration: Int = 60
    @FocusState private var isTitleFocused: Bool

    init(
        task: TaskItem?,
        exercises: [ExerciseType],
        onSave: @escaping (String, ExerciseType, Date?, Int?) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.task = task
        self.exercises = exercises
        self.onSave = onSave
        self.onDelete = onDelete

        if let task {
            _title = State(initialValue: task.title)
            _selectedExercise = State(initialValue: task.exerciseType)
            _hasDueDate = State(initialValue: task.dueDate != nil)
            _dueDate = State(initialValue: task.dueDate ?? Date())
            _customDuration = State(initialValue: task.exerciseType.duration)
        } else {
            let exercise = exercises.first ?? ExerciseType.preview
            _selectedExercise = State(initialValue: exercise)
            _customDuration = State(initialValue: exercise.duration)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                        .focused($isTitleFocused)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                }

                Section("Exercise") {
                    Picker("Pick exercise", selection: $selectedExercise) {
                        ForEach(exercises, id: \.self) { exercise in
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                Text("\(exercise.duration) sec • \(exercise.description)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(exercise)
                        }
                    }
                    .onChange(of: selectedExercise) { newValue in
                        customDuration = newValue.duration
                    }
                    Stepper(value: $customDuration, in: 5...900, step: 5) {
                        Text("Duration: \(customDuration) sec")
                    }
                }

                Section("Deadline") {
                    Toggle("Add due date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                if let onDelete, task != nil {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            Text("Delete task")
                        }
                    }
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .scrollContentBackground(.hidden)
            .background(Color("mainBack"))
            .tint(Color("Color1"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title.trimmingCharacters(in: .whitespacesAndNewlines), selectedExercise, hasDueDate ? dueDate : nil, customDuration)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isTitleFocused = true
                }
            }
        }
    }
}

#Preview {
    AddTaskView(
        task: nil,
        exercises: ExerciseType.defaultExercises,
        onSave: { _, _, _, _ in },
        onDelete: nil
    )
}
