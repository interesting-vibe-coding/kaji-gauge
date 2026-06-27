import Foundation

// MARK: - Provider configuration
//
// Per-provider display metadata. The glyph marks are placeholders — swap them
// for real brand marks later. This map is the single place to add/remove a
// provider's display config; the data layer surfaces whatever quota.py emits.
enum Providers {
    /// Unicode FALLBACK marks. claude / codex / gemini / minimax render real
    /// vector logos via `ProviderLogo` (Claude burst / OpenAI knot / Gemini
    /// spark / MiniMax M monogram); these marks are only used for providers
    /// without a vector logo.
    static let marks: [String: String] = [
        "claude":  "\u{2733}",   // ✳ burst — hints Claude's radial mark
        "codex":   "\u{273B}",   // ✻ six-petalled florette — hints OpenAI knot
        "minimax": "\u{272A}",   // ✪ circled white star — kept as fallback
        "gemini":  "\u{2726}",   // ✦ four-point spark — hints Gemini
        "ark-agent": "\u{25C7}",  // ◇
        "kiro":    "\u{25C9}",   // ◉
        "opencode": "\u{25B3}",  // △
    ]

    /// Human-facing display names (capitalized). Falls back to the raw key.
    static let displayNames: [String: String] = [
        "claude":  "Claude",
        "codex":   "Codex",
        "minimax": "MiniMax",
        "gemini":  "Gemini",
        "ark-agent": "Ark Agent",
        "kiro":    "Kiro",
        "opencode": "OpenCode",
    ]

    /// Preferred left-to-right display order. Providers not listed here are
    /// appended afterward in alphabetical order.
    static let order: [String] = [
        "claude", "codex", "ark-agent",
        "minimax", "gemini", "kiro", "opencode"
    ]

    /// Providers surfaced by default on a fresh install. Ark Agent is available
    /// in the toggle list when configured, but stays opt-in until quota is more
    /// trustworthy.
    /// MiniMax quota is wired through the `mmx` CLI (see `quota.py`'s
    /// `_fetch_minimax_limits`).
    static let visible: Set<String> = ["claude", "codex", "minimax"]
    static func isVisible(_ key: String) -> Bool { visible.contains(key) }

    /// Providers allowed into UI controls when quota.py emits them. This is
    /// intentionally broader than the default-visible set, but narrower than
    /// every diagnostic row quota.py can output.
    static let available: Set<String> = ["claude", "codex", "minimax", "ark-agent"]
    static func isAvailable(_ key: String) -> Bool { available.contains(key) }

    static func mark(for key: String) -> String {
        marks[key] ?? "\u{2022}" // • bullet fallback
    }

    static func displayName(for key: String) -> String {
        displayNames[key] ?? key.capitalized
    }

    /// Sort provider keys by the preferred order, then alphabetically.
    static func sorted(_ keys: [String]) -> [String] {
        keys.sorted { a, b in
            let ia = order.firstIndex(of: a) ?? Int.max
            let ib = order.firstIndex(of: b) ?? Int.max
            if ia != ib { return ia < ib }
            return a < b
        }
    }
}
