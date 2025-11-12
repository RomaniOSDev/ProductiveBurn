//
//  ContentView.swift
//  ProductiveBurn
//
//  Created by Роман Главацкий on 11.11.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @EnvironmentObject private var exerciseViewModel: ExerciseViewModel
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel

    var body: some View {
        ZStack {
            Color("mainBack")
                .ignoresSafeArea()

            TabView {
                NavigationStack {
                    MainTasksView()
                }
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

                NavigationStack {
                    SprintView()
                }
                .tabItem {
                    Label("Sprint", systemImage: "figure.run")
                }

                NavigationStack {
                    StatisticsView()
                }
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .tint(Color("Color1"))
        }
        .environmentObject(taskListViewModel)
        .environmentObject(exerciseViewModel)
        .environmentObject(statisticsViewModel)
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskListViewModel())
        .environmentObject(ExerciseViewModel(taskViewModel: TaskListViewModel()))
        .environmentObject(StatisticsViewModel(taskViewModel: TaskListViewModel()))
}
