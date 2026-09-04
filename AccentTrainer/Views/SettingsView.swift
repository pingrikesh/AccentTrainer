import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("openai_api_key") private var apiKey = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [PracticeRecord]
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("sk-... (optional)", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("Leave blank to use free built-in coaching. Add a key only if you want richer AI tips.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("OpenAI API Key (Optional)")
                } footer: {
                    Text("The app works fully without this. Paid API use is optional.")
                }

                Section("Permissions") {
                    Label("Microphone — required for recording", systemImage: "mic.fill")
                    Label("Speech Recognition — analyzes what you said", systemImage: "waveform")
                }

                Section("Data") {
                    LabeledContent("Saved Sessions", value: "\(records.count)")

                    Button("Clear All Progress", role: .destructive) {
                        showClearConfirmation = true
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Built for", value: "Personal practice")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Delete all saved sessions?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    records.forEach { modelContext.delete($0) }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: PracticeRecord.self, inMemory: true)
}
