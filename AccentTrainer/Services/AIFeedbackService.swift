import Foundation

enum AIFeedbackError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your OpenAI API key in Settings to enable AI coaching."
        case .invalidResponse:
            return "Could not parse the AI coaching response."
        case .serverError(let message):
            return message
        }
    }
}

actor AIFeedbackService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func generateFeedback(
        lesson: Lesson,
        analysis: AnalysisResult,
        apiKey: String
    ) async throws -> AIFeedbackResult {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { throw AIFeedbackError.missingAPIKey }

        let mismatched = analysis.wordAnalyses
            .filter { !$0.isCorrect }
            .map { "\($0.expected) → \($0.spoken ?? "missing")" }
            .joined(separator: ", ")

        let prompt = """
        You are an expert English pronunciation coach helping a learner improve accent, rhythm, and natural flow.

        Lesson: \(lesson.title)
        Focus sounds: \(lesson.focusSounds.joined(separator: ", "))
        Target sentence: \(lesson.text)
        What they said: \(analysis.transcript)
        Word accuracy score: \(Int(analysis.wordScore))%
        Fluency score: \(Int(analysis.fluencyScore))%
        Words per minute: \(Int(analysis.wordsPerMinute))
        Pauses detected: \(analysis.pauseCount)
        Mispronounced or missing words: \(mismatched.isEmpty ? "none" : mismatched)
        Coach tip for this lesson: \(lesson.tip)

        Respond ONLY with valid JSON in this exact shape:
        {
          "summary": "2-3 encouraging sentences about overall performance",
          "pronunciationTips": ["tip 1", "tip 2", "tip 3"],
          "rhythmTips": ["tip 1", "tip 2"],
          "practicePhrase": "one short phrase to repeat 5 times"
        }

        Be specific about mouth position, stress, linking, and intonation. Keep each tip under 20 words.
        """

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.4,
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": "You are a concise pronunciation coach. Always return valid JSON."],
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown API error"
            throw AIFeedbackError.serverError(message)
        }

        return try parseResponse(data)
    }

    private func parseResponse(_ data: Data) throws -> AIFeedbackResult {
        struct APIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        struct Payload: Decodable {
            let summary: String
            let pronunciationTips: [String]
            let rhythmTips: [String]
            let practicePhrase: String
        }

        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        guard let content = apiResponse.choices.first?.message.content.data(using: .utf8) else {
            throw AIFeedbackError.invalidResponse
        }

        let payload = try JSONDecoder().decode(Payload.self, from: content)

        return AIFeedbackResult(
            summary: payload.summary,
            pronunciationTips: payload.pronunciationTips,
            rhythmTips: payload.rhythmTips,
            practicePhrase: payload.practicePhrase
        )
    }
}
