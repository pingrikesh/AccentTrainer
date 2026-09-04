import Foundation

enum LocalCoachingService {
    static func generateFeedback(lesson: Lesson, analysis: AnalysisResult) -> AIFeedbackResult {
        let mismatched = analysis.wordAnalyses.filter { !$0.isCorrect }
        let summary = buildSummary(analysis: analysis, mismatchedCount: mismatched.count)

        var pronunciationTips: [String] = [lesson.tip]
        pronunciationTips.append(contentsOf: tipsForMismatchedWords(mismatched, focusSounds: lesson.focusSounds))
        if mismatched.isEmpty, analysis.wordScore >= 85 {
            pronunciationTips.append("Strong match. Focus on sounding natural, not robotic.")
        }

        let rhythmTips = rhythmTips(for: analysis)
        let practicePhrase = practicePhrase(for: lesson, mismatched: mismatched)

        return AIFeedbackResult(
            summary: summary,
            pronunciationTips: Array(pronunciationTips.prefix(4)),
            rhythmTips: rhythmTips,
            practicePhrase: practicePhrase
        )
    }

    private static func buildSummary(analysis: AnalysisResult, mismatchedCount: Int) -> String {
        let overall = Int(analysis.overallScore)

        if overall >= 85 {
            return "Great session — \(overall)% overall. Your words and flow are coming together well."
        }
        if mismatchedCount > 0 {
            return "You scored \(overall)%. \(mismatchedCount) word\(mismatchedCount == 1 ? "" : "s") need\(mismatchedCount == 1 ? "s" : "") more clarity — see the highlights below."
        }
        if analysis.fluencyScore < 70 {
            return "You scored \(overall)%. Your words were clear, but rhythm and pacing can improve."
        }
        return "You scored \(overall)% overall. Keep practicing this lesson to build muscle memory."
    }

    private static func tipsForMismatchedWords(_ mismatched: [WordAnalysis], focusSounds: [String]) -> [String] {
        guard !mismatched.isEmpty else { return [] }

        var tips: [String] = []
        for word in mismatched.prefix(3) {
            let expected = word.expected
            let spoken = word.spoken ?? "nothing"

            if word.spoken == nil {
                tips.append("You skipped \"\(expected)\" — say each word, even the small ones.")
            } else if soundTip(for: expected, focusSounds: focusSounds) != nil {
                tips.append(soundTip(for: expected, focusSounds: focusSounds)!)
            } else {
                tips.append("\"\(expected)\" sounded like \"\(spoken)\" — slow down and hit each syllable.")
            }
        }
        return tips
    }

    private static func soundTip(for word: String, focusSounds: [String]) -> String? {
        let lower = word.lowercased()

        if focusSounds.contains(where: { $0.lowercased() == "th" }) && (lower.contains("th") || ["think", "the", "weather", "this", "that"].contains(lower)) {
            return "For TH in \"\(word)\", tongue lightly between teeth — not F or D."
        }
        if focusSounds.contains(where: { $0.lowercased() == "r" }) && lower.contains("r") {
            return "For R in \"\(word)\", curl tongue back without touching the roof of your mouth."
        }
        if focusSounds.contains(where: { ["v", "w"].contains($0.lowercased()) }) {
            return "Check V (lip on teeth) vs W (rounded lips) in \"\(word)\"."
        }
        if focusSounds.contains(where: { ["ee", "ih"].contains($0.lowercased()) }) {
            return "Stretch long vowels in \"\(word)\" — short vs long makes a big difference."
        }
        return nil
    }

    private static func rhythmTips(for analysis: AnalysisResult) -> [String] {
        var tips: [String] = []

        if analysis.wordsPerMinute < 100 {
            tips.append("You're at \(Int(analysis.wordsPerMinute)) WPM — try a slightly faster, smoother pace (aim for 130–150).")
        } else if analysis.wordsPerMinute > 180 {
            tips.append("You're at \(Int(analysis.wordsPerMinute)) WPM — slow down slightly so each word lands clearly.")
        } else {
            tips.append("Good pace at \(Int(analysis.wordsPerMinute)) WPM. Keep it steady through the full sentence.")
        }

        if analysis.pauseCount > 2 {
            tips.append("You paused \(analysis.pauseCount) times — link words in phrases instead of stopping between each word.")
        } else if analysis.pauseCount == 0 && analysis.duration > 0 {
            tips.append("Smooth flow with few pauses. Now add natural stress on key words.")
        }

        return tips
    }

    private static func practicePhrase(for lesson: Lesson, mismatched: [WordAnalysis]) -> String {
        if let first = mismatched.first, first.expected != "—" {
            return first.expected
        }
        let words = lesson.text.split(separator: " ").prefix(4).joined(separator: " ")
        return words.isEmpty ? lesson.text : words
    }
}
