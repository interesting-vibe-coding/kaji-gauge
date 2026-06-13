import SwiftUI

// MARK: - Sparkline
//
// A thin polyline of the rolling 24h-ish history of 5h used% samples.
// (See QuotaStore — there is no real 24h series; this is a rolling buffer.)
private struct Sparkline: View {
    let values: [Double]   // 0...100 used%
    let color: Color

    var body: some View {
        GeometryReader { geo in
            Path { path in
                guard values.count >= 2 else { return }
                let w = geo.size.width
                let h = geo.size.height
                // Normalize to 0...100 so the line height reflects absolute use.
                let maxV = 100.0
                let minV = 0.0
                let span = max(maxV - minV, 1)
                let step = w / CGFloat(values.count - 1)
                for (i, v) in values.enumerated() {
                    let x = CGFloat(i) * step
                    let norm = (v - minV) / span
                    let y = h - CGFloat(norm) * h
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color.opacity(0.85),
                    style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - RingGauge
//
// The product's signature visual. Per provider: a single 5-hour ring.
//   - Background track circle (#3A3026 @ 50%, lineWidth 12, rounded caps).
//   - Value arc trimmed to usedFraction, rotated to start at 12 o'clock.
//   - Warm gold normally; same-family deeper AMBER when used% >= 80 (the
//     "near limit" alert). No neon orange, no glow — restrained / 淡雅.
//   - Color is NOT the only signal at >=80%: the cap thickens AND a small
//     alert tick is drawn at the arc head, so it reads without color.
//   - Center: provider mark glyph, big used% number, then a sparkline below.
//   - Below the ring: muted caption "周 {week}% · resets {reset}".
struct RingGauge: View {
    let provider: ProviderView

    // Geometry.
    private let ringSize: CGFloat = 96
    private let baseLineWidth: CGFloat = 12

    private var arcColor: Color {
        provider.isNearLimit ? Palette.amber : Palette.gold
    }

    // Thicken the value arc when near limit (non-color emphasis).
    private var valueLineWidth: CGFloat {
        provider.isNearLimit ? baseLineWidth + 3 : baseLineWidth
    }

    private var percentText: String {
        guard let p = provider.fiveHourPercent else { return "\u{2014}" } // —
        return "\(Int(p.rounded()))"
    }

    private var numberColor: Color {
        provider.isNearLimit ? Palette.amber : Palette.cream
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background track.
                Circle()
                    .stroke(Palette.track.opacity(0.5),
                            style: StrokeStyle(lineWidth: baseLineWidth, lineCap: .round))

                // Value arc.
                Circle()
                    .trim(from: 0, to: provider.usedFraction)
                    .stroke(arcColor,
                            style: StrokeStyle(lineWidth: valueLineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90)) // start at 12 o'clock
                    // No glow — alert reads via deeper amber + thicker cap + AlertTick.

                // Non-color alert tick at the arc head when near limit.
                if provider.isNearLimit && provider.usedFraction > 0 {
                    AlertTick(fraction: provider.usedFraction,
                              ringSize: ringSize,
                              lineWidth: valueLineWidth)
                        .stroke(Palette.cream,
                                style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }

                // Center stack: mark, big number, sparkline.
                VStack(spacing: 2) {
                    Text(provider.mark)
                        .font(.system(size: 19))
                        .foregroundColor(arcColor)

                    Text(percentText)
                        .font(.system(size: 27, weight: .semibold, design: .rounded))
                        .foregroundColor(numberColor)
                        .monospacedDigit()

                    Sparkline(values: provider.history, color: arcColor)
                        .frame(width: 34, height: 10)
                }
            }
            .frame(width: ringSize, height: ringSize)

            caption
        }
    }

    private var caption: some View {
        let week = provider.weekPercent.map { "\(Int($0.rounded()))%" } ?? "\u{2014}"
        let reset = ResetFormat.short(provider.resetDate)
        return Text("\u{5468} \(week) \u{00B7} resets \(reset)") // 周 {week} · resets {reset}
            .font(.system(size: 10))
            .foregroundColor(Palette.mute)
            .lineLimit(1)
    }
}

// MARK: - AlertTick
//
// A short radial line drawn at the arc head (12 o'clock + usedFraction). A
// second, color-independent signal that the ring is in alert state.
private struct AlertTick: Shape {
    let fraction: Double
    let ringSize: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        // Angle of the arc head: -90° (12 o'clock) + fraction of full turn.
        let angle = Angle.degrees(-90 + fraction * 360).radians
        let inner = radius - lineWidth / 2 - 3
        let outer = radius + lineWidth / 2 + 3
        let start = CGPoint(x: center.x + CGFloat(cos(angle)) * inner,
                            y: center.y + CGFloat(sin(angle)) * inner)
        let end = CGPoint(x: center.x + CGFloat(cos(angle)) * outer,
                          y: center.y + CGFloat(sin(angle)) * outer)
        p.move(to: start)
        p.addLine(to: end)
        return p
    }
}

// MARK: - Reset formatting
enum ResetFormat {
    /// "—" when no date; "2h 14m" style countdown for the future; "now" when
    /// already past (data is stale or window just rolled).
    static func short(_ date: Date?) -> String {
        guard let date = date else { return "\u{2014}" }
        let delta = date.timeIntervalSinceNow
        if delta <= 0 { return "now" }
        let hours = Int(delta) / 3600
        let mins = (Int(delta) % 3600) / 60
        if hours >= 24 {
            let days = hours / 24
            let rem = hours % 24
            return "\(days)d \(rem)h"
        }
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }
}
