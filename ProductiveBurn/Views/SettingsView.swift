import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @EnvironmentObject private var exerciseViewModel: ExerciseViewModel
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel

    @AppStorage("autoStartSprint") private var autoStartSprint: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

    @State private var showResetAlert = false
    @State private var showExportConfirmation = false

    var body: some View {
        ZStack {
            Color("mainBack")
                .ignoresSafeArea()

            Form {
                Section("Sprint") {
                    Toggle("Auto-start sprint when task is complete", isOn: $autoStartSprint)
                    Toggle("Enable sound cues", isOn: $soundEnabled)
                    Button {
                        exerciseViewModel.reset()
                    } label: {
                        Label("Stop current sprint", systemImage: "stop.fill")
                    }
                    .disabled(exerciseViewModel.state == .idle)
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset tasks and stats", systemImage: "trash")
                    }

                    Button {
                        exportTasks()
                    } label: {
                        Label("Export tasks", systemImage: "square.and.arrow.up")
                    }
                    .alert("Task list exported to the console log", isPresented: $showExportConfirmation) {
                        Button("OK", role: .cancel) { }
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Built by", value: "Fitness Sprints MVP")
                    Button {
                        requestReview()
                    } label: {
                        Label("Rate the app", systemImage: "star.fill")
                    }
                    Link("Privacy Policy", destination: URL(string: "https://www.termsfeed.com/live/88ac37ef-ce56-4fbd-809e-643018890b55")!)
                }
            }
            .scrollContentBackground(.hidden)
            .tint(Color("Color1"))
        }
        .navigationTitle("Settings")
        .alert("Delete all tasks?", isPresented: $showResetAlert, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                resetAllData()
            }
        }, message: {
            Text("This will erase every task and stat. You cannot undo this action.")
        })
    }

    private func resetAllData() {
        exerciseViewModel.reset()
        taskListViewModel.resetAllTasks()
    }

    private func exportTasks() {
        let tasks = taskListViewModel.tasks
        if let data = try? JSONEncoder().encode(tasks),
           let jsonString = String(data: data, encoding: .utf8) {
            print("[FITNESS-SPRINT EXPORT] \(jsonString)")
            showExportConfirmation = true
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(TaskListViewModel())
            .environmentObject(ExerciseViewModel(taskViewModel: TaskListViewModel()))
            .environmentObject(StatisticsViewModel(taskViewModel: TaskListViewModel()))
    }
}
