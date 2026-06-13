import SwiftUI

// MARK: - StatusItemView
//
// The compact menubar indicator: a tiny ring + "NN%" for the most-constrained
// provider. Renders into the NSStatusItem's button. Falls back to a neutral
// glyph + "—" when there is no data.
struct StatusItemView: View {
    let provider: ProviderView?

    private var percent: Int? {
        provider?.fiveHourPercent.map { Int($0.rounded()) }
    }

    private var nearLimit: Bool { provider?.isNearLimit ?? false }

    private var tint: Color { nearLimit ? Palette.amber : Palette.gold }

    var body: some View {
        HStack(spacing: 3) {
            ZStack {
                Circle()
                    .stroke(Palette.track.opacity(0.6),
                            style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
                Circle()
                    .trim(from: 0, to: provider?.usedFraction ?? 0)
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 13, height: 13)

            if let p = percent {
                Text("\(p)%")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(nearLimit ? Palette.amber : Palette.cream)
            } else {
                Text("\u{2014}") // —
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Palette.mute)
            }
        }
        .padding(.horizontal, 2)
        .frame(height: 22)
    }
}
