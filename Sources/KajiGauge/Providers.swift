import Foundation

// MARK: - Provider configuration
//
// Per-provider display metadata. The glyph marks are placeholders — swap them
// for real brand marks later. This map is the single place to add/remove a
// provider's display config; the data layer surfaces whatever quota.py emits.
enum Providers {
    /// Unicode FALLBACK marks. claude / codex / gemini now render real vector
    /// logos via `ProviderLogo` (Claude burst / OpenAI knot / Gemini spark);
    /// these marks are only used for providers without a vector logo.
    static let marks: [String: String] = [
        "claude":  "\u{2733}",   // ✳ burst — hints Claude's radial mark
        "codex":   "\u{273B}",   // ✻ six-petalled florette — hints OpenAI knot
        "minimax": "\u{272A}",   // ✪ circled white star — MiniMax mark
        "gemini":  "\u{2726}",   // ✦ four-point spark — hints Gemini
        "kiro":    "\u{25C9}",   // ◉
        "opencode": "\u{25B3}",  // △
    ]

    /// Human-facing display names (capitalized). Falls back to the raw key.
    static let displayNames: [String: String] = [
        "claude":  "Claude",
        "codex":   "Codex",
        "minimax": "MiniMax",
        "gemini":  "Gemini",
        "kiro":    "Kiro",
        "opencode": "OpenCode",
    ]

    /// Preferred left-to-right display order. Providers not listed here are
    /// appended afterward in alphabetical order.
    static let order: [String] = ["claude", "codex", "minimax", "gemini", "kiro", "opencode"]

    /// Providers we currently surface as rings. gemini / kiro / opencode are
    /// intentionally hidden for now — focus on claude + codex + minimax.
    /// MiniMax has no live local quota yet (no per-session files / quota API
    /// wired), so it renders an empty ring with the brand mark — the slot is
    /// reserved for when the API integration lands.
    static let visible: Set<String> = ["claude", "codex", "minimax"]
    static func isVisible(_ key: String) -> Bool { visible.contains(key) }

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
