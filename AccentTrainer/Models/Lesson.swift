import Foundation

struct Lesson: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let category: LessonCategory
    let text: String
    let focusSounds: [String]
    let tip: String
    let difficulty: Int

    enum LessonCategory: String, Codable, CaseIterable {
        case sounds = "Sounds"
        case rhythm = "Rhythm & Flow"
        case sentences = "Sentences"
        case conversation = "Conversation"
    }
}

struct LessonBundle: Codable {
    let lessons: [Lesson]
}
