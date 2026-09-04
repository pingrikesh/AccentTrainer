import Foundation

@MainActor
final class LessonStore: ObservableObject {
    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var loadError: String?

    init() {
        loadLessons()
    }

    func lessons(for category: Lesson.LessonCategory) -> [Lesson] {
        lessons.filter { $0.category == category }
    }

    func lesson(id: String) -> Lesson? {
        lessons.first { $0.id == id }
    }

    private func loadLessons() {
        guard let url = Bundle.main.url(forResource: "lessons", withExtension: "json") else {
            loadError = "lessons.json not found in the app bundle."
            lessons = Self.fallbackLessons
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let bundle = try JSONDecoder().decode(LessonBundle.self, from: data)
            lessons = bundle.lessons
        } catch {
            loadError = error.localizedDescription
            lessons = Self.fallbackLessons
        }
    }

    private static let fallbackLessons: [Lesson] = [
        Lesson(
            id: "fallback-1",
            title: "Warm Up",
            category: .sentences,
            text: "Good morning, how are you today?",
            focusSounds: ["th", "r"],
            tip: "Relax your jaw and finish each word clearly.",
            difficulty: 1
        )
    ]
}
