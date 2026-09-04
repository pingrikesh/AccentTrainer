import SwiftUI

struct ContentView: View {
    @StateObject private var lessonStore = LessonStore()

    var body: some View {
        TabView {
            LessonListView()
                .tabItem {
                    Label("Practice", systemImage: "mic.fill")
                }

            ProgressDashboardView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .environmentObject(lessonStore)
        .tint(Color.accentColor)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PracticeRecord.self, inMemory: true)
}
