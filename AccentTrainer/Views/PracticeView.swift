import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PracticeViewModel

    init(lesson: Lesson) {
        _viewModel = StateObject(wrappedValue: PracticeViewModel(lesson: lesson))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                lessonCard
                statusCard
                controlsCard

                if let analysis = viewModel.analysis {
                    resultsSection(analysis)
                }

                if let feedback = viewModel.aiFeedback {
                    aiFeedbackSection(feedback)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.phase == .results {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.saveRecord(context: modelContext)
                    }
                }
            }
        }
    }

    private var lessonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(viewModel.lesson.category.rawValue, systemImage: "book.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(viewModel.lesson.text)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text(viewModel.lesson.tip)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                viewModel.playReference()
            } label: {
                Label("Hear Reference", systemImage: "speaker.wave.2.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.recorder.isRecording || viewModel.phase == .analyzing)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            if viewModel.phase == .analyzing {
                ProgressView()
            } else {
                Image(systemName: phaseIcon)
                    .foregroundStyle(phaseColor)
            }
            Text(viewModel.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controlsCard: some View {
        VStack(spacing: 16) {
            RecordingButton(
                isRecording: viewModel.recorder.isRecording,
                isDisabled: viewModel.phase == .analyzing
            ) {
                Task { await viewModel.toggleRecording() }
            }

            HStack {
                if viewModel.recorder.recordingURL != nil, viewModel.phase != .recording {
                    Button("Play Recording") {
                        try? viewModel.recorder.playRecording()
                    }
                    .buttonStyle(.bordered)
                }

                if viewModel.phase == .results {
                    Button("Try Again") {
                        viewModel.reset()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func resultsSection(_ analysis: AnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Results")
                .font(.headline)

            HStack(spacing: 16) {
                ScoreRing(title: "Overall", score: analysis.overallScore, color: .green)
                ScoreRing(title: "Words", score: analysis.wordScore, color: .blue)
                ScoreRing(title: "Flow", score: analysis.fluencyScore, color: .purple)
            }

            HStack {
                StatPill(label: "WPM", value: "\(Int(analysis.wordsPerMinute))")
                StatPill(label: "Pauses", value: "\(analysis.pauseCount)")
                StatPill(label: "Time", value: String(format: "%.1fs", analysis.duration))
            }

            WordHighlightView(analyses: analysis.wordAnalyses)

            VStack(alignment: .leading, spacing: 6) {
                Text("Transcript")
                    .font(.subheadline.weight(.semibold))
                Text(analysis.transcript)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func aiFeedbackSection(_ feedback: AIFeedbackResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Coach", systemImage: "text.bubble.fill")
                .font(.headline)

            Text(feedback.summary)
                .font(.body)

            FeedbackList(title: "Pronunciation", items: feedback.pronunciationTips)
            FeedbackList(title: "Rhythm & Flow", items: feedback.rhythmTips)

            VStack(alignment: .leading, spacing: 6) {
                Text("Repeat This")
                    .font(.subheadline.weight(.semibold))
                Text(feedback.practicePhrase)
                    .font(.body.italic())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var phaseIcon: String {
        switch viewModel.phase {
        case .ready: return "mic"
        case .recording: return "waveform"
        case .analyzing: return "hourglass"
        case .results: return "checkmark.circle.fill"
        }
    }

    private var phaseColor: Color {
        switch viewModel.phase {
        case .ready: return .secondary
        case .recording: return .red
        case .analyzing: return .orange
        case .results: return .green
        }
    }
}

private struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct FeedbackList: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PracticeView(
            lesson: Lesson(
                id: "preview",
                title: "TH Sound",
                category: .sounds,
                text: "I think the weather is beautiful today.",
                focusSounds: ["th"],
                tip: "Place your tongue lightly between your teeth for TH.",
                difficulty: 1
            )
        )
    }
    .modelContainer(for: PracticeRecord.self, inMemory: true)
}
