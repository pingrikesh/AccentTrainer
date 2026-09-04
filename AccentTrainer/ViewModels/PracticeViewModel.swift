import SwiftUI
import SwiftData

@MainActor
final class PracticeViewModel: ObservableObject {
    enum Phase: Equatable {
        case ready
        case recording
        case analyzing
        case results
    }

    @Published var phase: Phase = .ready
    @Published var analysis: AnalysisResult?
    @Published var aiFeedback: AIFeedbackResult?
    @Published var errorMessage: String?
    @Published var statusMessage = "Tap the microphone and read the sentence aloud."

    let lesson: Lesson
    let recorder = AudioRecorderService()
    let tts = TextToSpeechService()

    private let speechAnalyzer = SpeechAnalyzerService()
    private let aiService = AIFeedbackService()

    init(lesson: Lesson) {
        self.lesson = lesson
    }

    func playReference() {
        tts.speak(lesson.text)
    }

    func toggleRecording() async {
        errorMessage = nil

        if recorder.isRecording {
            guard let url = recorder.stopRecording() else { return }
            await analyzeRecording(url: url)
            return
        }

        let micGranted = await recorder.requestPermission()
        guard micGranted else {
            errorMessage = "Microphone access is required to practice."
            return
        }

        let speechGranted = await speechAnalyzer.requestAuthorization()
        guard speechGranted else {
            errorMessage = SpeechAnalyzerError.notAuthorized.localizedDescription
            return
        }

        do {
            try recorder.startRecording()
            phase = .recording
            statusMessage = "Listening… speak naturally, then tap stop."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        analysis = nil
        aiFeedback = nil
        errorMessage = nil
        phase = .ready
        statusMessage = "Tap the microphone and read the sentence aloud."
        recorder.stopPlayback()
        tts.stop()
    }

    private func analyzeRecording(url: URL) async {
        phase = .analyzing
        statusMessage = "Analyzing your pronunciation…"

        do {
            let transcription = try await speechAnalyzer.transcribe(audioURL: url)
            let result = PronunciationScorer.analyze(
                expected: lesson.text,
                spoken: transcription.text,
                duration: transcription.duration,
                pauseCount: transcription.pauseCount
            )

            analysis = result
            phase = .results

            if AppSettings.hasAPIKey {
                statusMessage = "Getting AI coaching…"
                do {
                    aiFeedback = try await aiService.generateFeedback(
                        lesson: lesson,
                        analysis: result,
                        apiKey: AppSettings.openAIAPIKey
                    )
                    statusMessage = "Coaching ready."
                } catch {
                    aiFeedback = LocalCoachingService.generateFeedback(lesson: lesson, analysis: result)
                    statusMessage = "Using built-in coaching (AI unavailable)."
                }
            } else {
                aiFeedback = LocalCoachingService.generateFeedback(lesson: lesson, analysis: result)
                statusMessage = "Session complete."
            }
        } catch {
            errorMessage = error.localizedDescription
            phase = .ready
            statusMessage = "Try again when you're ready."
        }
    }

    func saveRecord(context: ModelContext) {
        guard let analysis, let feedback = aiFeedback else { return }

        let feedbackText = """
        \(feedback.summary)

        Pronunciation:
        \(feedback.pronunciationTips.map { "• \($0)" }.joined(separator: "\n"))

        Rhythm:
        \(feedback.rhythmTips.map { "• \($0)" }.joined(separator: "\n"))

        Practice: \(feedback.practicePhrase)
        """

        let record = PracticeRecord(
            lessonId: lesson.id,
            lessonTitle: lesson.title,
            expectedText: lesson.text,
            transcript: analysis.transcript,
            wordScore: analysis.wordScore,
            fluencyScore: analysis.fluencyScore,
            overallScore: analysis.overallScore,
            wordsPerMinute: analysis.wordsPerMinute,
            aiFeedback: feedbackText
        )
        context.insert(record)
    }
}
