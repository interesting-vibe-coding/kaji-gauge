import SwiftUI

// MARK: - GaugeRowView
//
// A horizontal row of ring gauges, one per provider. Shared by both surfaces
// (the menubar popover and the floating panel) so the two always render the
// same content from the same store.
struct GaugeRowView: View {
    @ObservedObject var store: QuotaStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            if store.providers.isEmpty {
                emptyState
            } else {
                HStack(alignment: .top, spacing: 18) {
                    ForEach(store.providers) { provider in
                        RingGauge(provider: provider)
                    }
                }
            }

            footer
        }
        .padding(16)
        .background(Palette.bg)
    }

    private var header: some View {
        HStack {
            Text("Kaji Gauge")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Palette.cream)
            Spacer()
            Text("5h quota")
                .font(.system(size: 10))
                .foregroundColor(Palette.ash)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Text("\u{2014}") // —
                .font(.system(size: 28))
                .foregroundColor(Palette.ash)
            Text(store.lastError ?? "waiting for quota\u{2026}")
                .font(.system(size: 10))
                .foregroundColor(Palette.mute)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }

    private var footer: some View {
        HStack {
            if let err = store.lastError, !store.providers.isEmpty {
                Text("stale: \(err)")
                    .font(.system(size: 9))
                    .foregroundColor(Palette.amber.opacity(0.85))
                    .lineLimit(1)
            } else if let updated = store.lastUpdated {
                Text("updated \(ResetFormat.ago(updated))")
                    .font(.system(size: 9))
                    .foregroundColor(Palette.ash)
            }
            Spacer()
        }
    }
}

extension ResetFormat {
    /// Compact "Ns/Nm/Nh ago" for the last-updated footer.
    static func ago(_ date: Date) -> String {
        let d = -date.timeIntervalSinceNow
        if d < 60 { return "\(Int(d))s ago" }
        if d < 3600 { return "\(Int(d / 60))m ago" }
        return "\(Int(d / 3600))h ago"
    }
}
