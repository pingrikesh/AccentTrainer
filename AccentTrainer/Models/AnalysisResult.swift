import Foundation

struct WordAnalysis: Identifiable, Hashable {
    let id = UUID()
    let expected: String
    let spoken: String?
    let isCorrect: Bool
}

struct AnalysisResult {
    let transcript: String
    let wordAnalyses: [WordAnalysis]
    let wordScore: Double
    let fluencyScore: Double
    let overallScore: Double
    let wordsPerMinute: Double
    let pauseCount: Int
    let duration: TimeInterval
}

struct AIFeedbackResult {
    let summary: String
    let pronunciationTips: [String]
    let rhythmTips: [String]
    let practicePhrase: String
}
