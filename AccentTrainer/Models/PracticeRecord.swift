import Foundation
import SwiftData

@Model
final class PracticeRecord: Identifiable {
    var id: UUID
    var lessonId: String
    var lessonTitle: String
    var expectedText: String
    var transcript: String
    var wordScore: Double
    var fluencyScore: Double
    var overallScore: Double
    var wordsPerMinute: Double
    var aiFeedback: String
    var createdAt: Date

    init(
        lessonId: String,
        lessonTitle: String,
        expectedText: String,
        transcript: String,
        wordScore: Double,
        fluencyScore: Double,
        overallScore: Double,
        wordsPerMinute: Double,
        aiFeedback: String
    ) {
        self.id = UUID()
        self.lessonId = lessonId
        self.lessonTitle = lessonTitle
        self.expectedText = expectedText
        self.transcript = transcript
        self.wordScore = wordScore
        self.fluencyScore = fluencyScore
        self.overallScore = overallScore
        self.wordsPerMinute = wordsPerMinute
        self.aiFeedback = aiFeedback
        self.createdAt = Date()
    }
}
