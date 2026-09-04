import SwiftUI

struct ScoreRing: View {
    let title: String
    let score: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(score))")
                    .font(.headline)
            }
            .frame(width: 72, height: 72)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HStack {
        ScoreRing(title: "Overall", score: 82, color: .green)
        ScoreRing(title: "Words", score: 76, color: .blue)
    }
    .padding()
}
