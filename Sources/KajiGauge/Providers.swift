import Foundation

// MARK: - Provider configuration
//
// Per-provider display metadata. The glyph marks are placeholders — swap them
// for real brand marks later. This map is the single place to add/remove a
// provider's display config; the data layer surfaces whatever quota.py emits.
enum Providers {
    /// Glyph marks shown in the ring center, tinted to the ring color. These are
    /// Unicode placeholders chosen to hint each brand. Official brand vector
    /// logos (Claude burst / OpenAI knot / Gemini spark) are a TODO — bundle
    /// them as assets; the design preview has accurate SVGs to convert.
    /// (No emoji marks — the crab is gone.)
    static let marks: [String: String] = [
        "claude": "\u{2733}",   // ✳ burst — hints Claude's radial mark
        "codex":  "\u{273B}",   // ✻ six-petalled florette — hints OpenAI knot
        "gemini": "\u{2726}",   // ✦ four-point spark — hints Gemini
        "kiro":   "\u{25C9}",   // ◉
        "opencode": "\u{25B3}", // △
    ]

    /// Human-facing display names (capitalized). Falls back to the raw key.
    static let displayNames: [String: String] = [
        "claude": "Claude",
        "codex":  "Codex",
        "gemini": "Gemini",
        "kiro":   "Kiro",
        "opencode": "OpenCode",
    ]

    /// Preferred left-to-right display order. Providers not listed here are
    /// appended afterward in alphabetical order.
    static let order: [String] = ["claude", "codex", "gemini", "kiro", "opencode"]

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
