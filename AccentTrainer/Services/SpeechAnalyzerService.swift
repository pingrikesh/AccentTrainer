import Foundation
import Speech

enum SpeechAnalyzerError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case noTranscript

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition permission was denied. Enable it in Settings."
        case .recognizerUnavailable:
            return "Speech recognition is not available for English (US) on this device."
        case .noTranscript:
            return "Could not understand your speech. Try speaking closer to the microphone."
        }
    }
}

struct SpeechTranscription {
    let text: String
    let duration: TimeInterval
    let pauseCount: Int
    let segmentCount: Int
}

actor SpeechAnalyzerService {
    private let locale = Locale(identifier: "en-US")

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func transcribe(audioURL: URL) async throws -> SpeechTranscription {
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw SpeechAnalyzerError.recognizerUnavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<SFSpeechRecognitionResult, Error>) in
            var hasResumed = false
            recognizer.recognitionTask(with: request) { result, error in
                if hasResumed { return }

                if let error {
                    hasResumed = true
                    continuation.resume(throwing: error)
                    return
                }

                guard let result, result.isFinal else { return }
                hasResumed = true
                continuation.resume(returning: result)
            }
        }

        let transcription = result.bestTranscription
        let text = transcription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw SpeechAnalyzerError.noTranscript }

        let segments = transcription.segments
        let duration = segments.last.map { $0.timestamp + $0.duration } ?? 0
        let pauseCount = countPauses(in: segments)

        return SpeechTranscription(
            text: text,
            duration: max(duration, 0.1),
            pauseCount: pauseCount,
            segmentCount: segments.count
        )
    }

    private func countPauses(in segments: [SFTranscriptionSegment]) -> Int {
        guard segments.count > 1 else { return 0 }

        var pauses = 0
        for index in 1..<segments.count {
            let previousEnd = segments[index - 1].timestamp + segments[index - 1].duration
            let gap = segments[index].timestamp - previousEnd
            if gap > 0.35 {
                pauses += 1
            }
        }
        return pauses
    }
}
