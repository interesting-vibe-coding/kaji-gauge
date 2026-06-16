import SwiftUI

// MARK: - DockStripView
//
// The visual shown when the floating HUD is `.docked` against a screen edge.
// A 36pt thin strip hosting:
//   - the mostConstrained provider's logo + 5h % + reset countdown, on the
//     SCREEN-edge side of the strip.
//   - a curved handle ("ear") on the PANEL-facing side, with a chevron
//     pointing the way the panel will unfold. Click handle (or anywhere on
//     the strip) → `onExpand()`.
//
// Layout is done natively via HStack / VStack — no rotation. The strip's
// long axis (height for left/right docks, width for top/bottom docks) is laid
// out the way the eye reads it, so the chevron + percent text never need
// a transform.
struct DockStripView: View {
    @ObservedObject var store: QuotaStore
    @ObservedObject var prefs: Prefs
    let edge: DockEdge
    let onExpand: () -> Void

    @Environment(\.colorScheme) private var scheme
    private var t: KajiTheme { .resolve(scheme) }

    /// The provider currently closest to its 5h limit. Falls back to the
    /// first available if none have data (we always show *something*).
    private var provider: ProviderView? {
        if let m = store.mostConstrained { return m }
        return store.providers.first
    }

    var body: some View {
        // Handle sits on the PANEL-facing side, content on the SCREEN-edge
        // side. No rotation — the long axis is laid out natively.
        Group {
            switch edge {
            case .left:
                HStack(spacing: 0) { handle; content }
            case .right:
                HStack(spacing: 0) { content; handle }
            case .top:
                VStack(spacing: 0) { handle; content }
            case .bottom:
                VStack(spacing: 0) { content; handle }
            }
        }
        .background(stripBg)
        .overlay(stripOutline)
        .clipShape(stripShape)
        .contentShape(stripShape)
        .onTapGesture(perform: onExpand)
    }

    // MARK: Background + shape

    private var stripBg: some View {
        // Same warm paper/ink gradient as the full HUD so the docked strip
        // doesn't look like a foreign object on the desktop.
        LinearGradient(
            colors: [t.bgTop, t.bg],
            startPoint: .topTrailing, endPoint: .bottomLeading
        )
    }

    private var stripOutline: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(t.gold.opacity(0.55), lineWidth: 1)
    }

    /// Capsule on both ends — the panel-facing edge already curves gracefully,
    /// and the dedicated handle View on top of it pops as the affordance.
    private var stripShape: some Shape {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
    }

    // MARK: Content (logo + % + countdown)

    private var content: some View {
        VStack(spacing: 3) {
            logo
            percentLabel
            countdownLabel
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var logo: some View {
        if let p = provider {
            ProviderLogo(key: p.id, color: t.cream, size: 13)
        } else {
            // No providers yet — a tiny dot to mark the strip as ours.
            Circle().fill(t.ash).frame(width: 5, height: 5)
        }
    }

    private var percentLabel: some View {
        let text: String = {
            guard let p = provider, let raw = p.fiveHourPercent else { return "—" }
            let shown = prefs.showRemaining ? (100 - raw) : raw
            return "\(Int(shown.rounded()))%"
        }()
        return Text(text)
            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
            .foregroundColor(t.gold)
            .lineLimit(1)
            .fixedSize()  // don't shrink — readability wins in a 36pt strip
    }

    private var countdownLabel: some View {
        Text(countdownText)
            .font(.system(size: 8.5, weight: .regular, design: .monospaced))
            .foregroundColor(t.cream.opacity(0.55))
            .lineLimit(1)
            .fixedSize()
    }

    /// "5h12m" or "12m" or "" when no data. Matches the menubar's compact
    /// style — short enough to fit a 36pt strip without truncation.
    private var countdownText: String {
        guard let p = provider, let reset = p.resetDate else { return "·" }
        let secs = max(0, Int(reset.timeIntervalSinceNow))
        if secs <= 0 { return "now" }
        let h = secs / 3600
        let m = (secs % 3600) / 60
        return h > 0 ? "\(h)h\(m)m" : "\(m)m"
    }

    // MARK: Handle (panel-facing side)

    /// Curved pill on the inner side of the strip. The chevron points the
    /// way the panel will unfold. Has its own gold-tinted backdrop so it
    /// visually pops as "this is the button" against the warm-paper strip.
    /// The whole strip is also tappable as a fallback.
    private var handle: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(t.gold.opacity(0.18))
                .overlay(Capsule(style: .continuous)
                    .stroke(t.gold.opacity(0.7), lineWidth: 1))
            Image(systemName: chevronName)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(t.gold)
        }
        .frame(width: handleSize.width, height: handleSize.height)
        .padding(3)
        .contentShape(Rectangle())
        .onTapGesture(perform: onExpand)
    }

    /// Tall thin pill on left/right docks, short wide pill on top/bottom.
    /// Sized so it reads as a "tab" inside the strip without competing with
    /// the logo / percentage content.
    private var handleSize: CGSize {
        switch edge {
        case .left, .right:
            return CGSize(width: 14, height: 44)
        case .top, .bottom:
            return CGSize(width: 44, height: 14)
        }
    }

    /// Chevron points WHERE the panel will unfold toward when the user clicks.
    private var chevronName: String {
        switch edge {
        case .left:   return "chevron.right"   // panel unrolls to the right
        case .right:  return "chevron.left"    // panel unrolls to the left
        case .top:    return "chevron.down"    // panel unrolls down
        case .bottom: return "chevron.up"      // panel unrolls up
        }
    }
}