import Foundation

enum PronunciationScorer {
    static func analyze(
        expected: String,
        spoken: String,
        duration: TimeInterval,
        pauseCount: Int
    ) -> AnalysisResult {
        let expectedWords = tokenize(expected)
        let spokenWords = tokenize(spoken)

        var analyses: [WordAnalysis] = []
        let maxCount = max(expectedWords.count, spokenWords.count)

        var correctCount = 0
        for index in 0..<maxCount {
            let expectedWord = index < expectedWords.count ? expectedWords[index] : ""
            let spokenWord = index < spokenWords.count ? spokenWords[index] : nil

            let isCorrect = spokenWord.map { fuzzyMatch(expectedWord, $0) } ?? false
            if isCorrect { correctCount += 1 }

            analyses.append(
                WordAnalysis(
                    expected: expectedWord.isEmpty ? "—" : expectedWord,
                    spoken: spokenWord,
                    isCorrect: isCorrect
                )
            )
        }

        let wordScore = expectedWords.isEmpty
            ? 0
            : (Double(correctCount) / Double(expectedWords.count)) * 100

        let wpm = duration > 0
            ? (Double(spokenWords.count) / duration) * 60
            : 0

        let fluencyScore = fluencyScore(
            wordsPerMinute: wpm,
            pauseCount: pauseCount,
            spokenWordCount: spokenWords.count
        )

        let overallScore = (wordScore * 0.65) + (fluencyScore * 0.35)

        return AnalysisResult(
            transcript: spoken,
            wordAnalyses: analyses,
            wordScore: wordScore,
            fluencyScore: fluencyScore,
            overallScore: overallScore,
            wordsPerMinute: wpm,
            pauseCount: pauseCount,
            duration: duration
        )
    }

    private static func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }

    private static func fuzzyMatch(_ expected: String, _ spoken: String) -> Bool {
        if expected == spoken { return true }
        if levenshtein(expected, spoken) <= 1 { return true }
        if expected.count > 3, spoken.hasPrefix(String(expected.prefix(expected.count - 1))) { return true }
        return false
    }

    private static func fluencyScore(wordsPerMinute: Double, pauseCount: Int, spokenWordCount: Int) -> Double {
        var score = 100.0

        let idealWPM = 140.0
        let wpmDelta = abs(wordsPerMinute - idealWPM)
        score -= min(wpmDelta / 2.5, 35)

        if spokenWordCount > 0 {
            let pauseRatio = Double(pauseCount) / Double(spokenWordCount)
            score -= min(pauseRatio * 120, 40)
        }

        if wordsPerMinute < 70 { score -= 15 }
        if wordsPerMinute > 210 { score -= 10 }

        return max(0, min(100, score))
    }

    private static func levenshtein(_ lhs: String, _ rhs: String) -> Int {
        let left = Array(lhs)
        let right = Array(rhs)
        var distances = Array(0...right.count)

        for i in 1...left.count {
            var previous = distances[0]
            distances[0] = i
            for j in 1...right.count {
                let cost = left[i - 1] == right[j - 1] ? 0 : 1
                let replacement = previous + cost
                let insertion = distances[j] + 1
                let deletion = distances[j - 1] + 1
                previous = distances[j]
                distances[j] = min(replacement, insertion, deletion)
            }
        }

        return distances[right.count]
    }
}
