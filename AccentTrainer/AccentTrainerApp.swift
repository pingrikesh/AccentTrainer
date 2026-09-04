import SwiftUI
import SwiftData

@main
struct AccentTrainerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PracticeRecord.self)
    }
}
