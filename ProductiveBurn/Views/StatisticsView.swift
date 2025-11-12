import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct StatisticsView: View {
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel

    private var snapshot: TaskStatisticsSnapshot { statisticsViewModel.snapshot }

    var body: some View {
        ZStack {
            Color("mainBack")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    metricCards
                    weeklyChart
                    workoutSummary
                }
                .padding()
            }
        }
        .navigationTitle("Statistics")
    }

    private var metricCards: some View {
        HStack(spacing: 16) {
            StatisticCard(title: "Today", value: "\(snapshot.completedToday)", subtitle: "completed")
            StatisticCard(title: "This Week", value: "\(snapshot.completedThisWeek)", subtitle: "tasks")
        }
    }

    @ViewBuilder
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completed this week")
                .font(.headline)
            if snapshot.weeklyCompletions.isEmpty {
                Text("No data yet—let's get moving!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if #available(iOS 16.0, *), canImportCharts {
#if canImport(Charts)
                Chart(snapshot.weeklyCompletions) { entry in
                    BarMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Tasks", entry.count)
                    )
                    .foregroundStyle(LinearGradient(colors: [Color("Color1"), Color("Color2")], startPoint: .bottom, endPoint: .top))
                }
                .frame(height: 220)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
#endif
            } else {
                ForEach(snapshot.weeklyCompletions) { entry in
                    HStack {
                        Text(entry.date, style: .date)
                            .frame(width: 80, alignment: .leading)
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            let maxCount = max(snapshot.weeklyCompletions.map { $0.count }.max() ?? 1, 1)
                            let barWidth = CGFloat(entry.count) / CGFloat(maxCount) * width
                            Rectangle()
                                .fill(Color("Color1").opacity(0.7))
                                .frame(width: barWidth, height: 12)
                                .cornerRadius(6)
                                .animation(.easeInOut, value: entry.count)
                        }
                        .frame(height: 16)
                        Text("\(entry.count)")
                            .frame(width: 32, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color("Color2").opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var workoutSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total workout time")
                .font(.headline)
            Text(totalWorkoutTimeFormatted)
                .font(.title)
                .fontWeight(.semibold)
            Text("Sum of workout times for completed tasks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Color2").opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var totalWorkoutTimeFormatted: String {
        let minutes = snapshot.totalWorkoutSeconds / 60
        let seconds = snapshot.totalWorkoutSeconds % 60
        return minutes > 0 ? "\(minutes) min \(seconds) sec" : "\(seconds) sec"
    }
}

private struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Color2").opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private var canImportCharts: Bool {
    #if canImport(Charts)
    true
    #else
    false
    #endif
}

#Preview {
    StatisticsView()
        .environmentObject(StatisticsViewModel(taskViewModel: TaskListViewModel()))
}
