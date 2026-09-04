import SwiftUI

struct LessonListView: View {
    @EnvironmentObject private var lessonStore: LessonStore
    @State private var selectedCategory: Lesson.LessonCategory = .sounds

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(Lesson.LessonCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List(lessonStore.lessons(for: selectedCategory)) { lesson in
                    NavigationLink(value: lesson) {
                        LessonRowView(lesson: lesson)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Accent Trainer")
            .navigationDestination(for: Lesson.self) { lesson in
                PracticeView(lesson: lesson)
            }
        }
    }
}

private struct LessonRowView: View {
    let lesson: Lesson

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(lesson.title)
                    .font(.headline)
                Spacer()
                DifficultyBadge(level: lesson.difficulty)
            }

            Text(lesson.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 6) {
                ForEach(lesson.focusSounds.prefix(3), id: \.self) { sound in
                    Text(sound)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DifficultyBadge: View {
    let level: Int

    var body: some View {
        Text("L\(level)")
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    LessonListView()
        .environmentObject(LessonStore())
}
