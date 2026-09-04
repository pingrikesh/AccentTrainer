import SwiftUI

struct WordHighlightView: View {
    let analyses: [WordAnalysis]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Word Match")
                .font(.subheadline.weight(.semibold))

            FlowLayout(spacing: 8) {
                ForEach(analyses) { analysis in
                    Text(analysis.expected)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(analysis.isCorrect ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        .foregroundStyle(analysis.isCorrect ? .green : .red)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

#Preview {
    WordHighlightView(analyses: [
        WordAnalysis(expected: "think", spoken: "think", isCorrect: true),
        WordAnalysis(expected: "weather", spoken: "wether", isCorrect: false),
        WordAnalysis(expected: "today", spoken: "today", isCorrect: true)
    ])
    .padding()
}
