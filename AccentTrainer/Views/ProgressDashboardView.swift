import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query(sort: \PracticeRecord.createdAt, order: .reverse) private var records: [PracticeRecord]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "chart.bar.doc.horizontal",
                        description: Text("Complete a practice session and tap Save to track your progress.")
                    )
                } else {
                    List {
                        Section("Overview") {
                            HStack {
                                OverviewStat(title: "Sessions", value: "\(records.count)")
                                OverviewStat(title: "Avg Score", value: "\(averageScore)%")
                                OverviewStat(title: "Streak", value: "\(currentStreak)d")
                            }
                            .listRowBackground(Color.clear)
                        }

                        Section("Recent Sessions") {
                            ForEach(records) { record in
                                NavigationLink {
                                    SessionDetailView(record: record)
                                } label: {
                                    SessionRowView(record: record)
                                }
                            }
                            .onDelete(perform: deleteRecords)
                        }
                    }
                }
            }
            .navigationTitle("Progress")
        }
    }

    private var averageScore: Int {
        guard !records.isEmpty else { return 0 }
        let total = records.reduce(0.0) { $0 + $1.overallScore }
        return Int(total / Double(records.count))
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.createdAt) }).sorted(by: >)
        guard let latest = uniqueDays.first else { return 0 }

        var streak = 0
        var checkDate = latest

        for day in uniqueDays {
            if day == checkDate {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previous
            } else if day < checkDate {
                break
            }
        }

        return streak
    }

    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }
}

private struct OverviewStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SessionRowView: View {
    let record: PracticeRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.lessonTitle)
                    .font(.headline)
                Spacer()
                Text("\(Int(record.overallScore))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            }

            Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(record.transcript)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

struct SessionDetailView: View {
    let record: PracticeRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ScoreRing(title: "Overall", score: record.overallScore, color: .green)
                    ScoreRing(title: "Words", score: record.wordScore, color: .blue)
                    ScoreRing(title: "Flow", score: record.fluencyScore, color: .purple)
                }

                GroupBox("Expected") {
                    Text(record.expectedText)
                }

                GroupBox("You Said") {
                    Text(record.transcript)
                }

                GroupBox("AI Feedback") {
                    Text(record.aiFeedback)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle(record.lessonTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProgressDashboardView()
        .modelContainer(for: PracticeRecord.self, inMemory: true)
}
