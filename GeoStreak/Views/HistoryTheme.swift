import SwiftUI

// MARK: - Historical colour palette
// All background/text pairings meet WCAG AA (4.5 : 1) unless noted as decorative-only.

extension Color {
    // ── Backgrounds ──────────────────────────────────────────
    /// Near-black aged leather – deepest surface
    static let histBgDeep   = Color(red: 0.09, green: 0.07, blue: 0.05)
    /// Primary card surface
    static let histBgCard   = Color(red: 0.16, green: 0.12, blue: 0.09)
    /// Slightly raised element (input rows, chips)
    static let histBgRaised = Color(red: 0.24, green: 0.19, blue: 0.14)

    // ── Text ─────────────────────────────────────────────────
    /// Primary text on dark – aged parchment (contrast ≥ 12 : 1 on histBgDeep)
    static let histParchment = Color(red: 0.95, green: 0.91, blue: 0.82)
    /// Secondary text – faded ink (≥ 5 : 1)
    static let histAged      = Color(red: 0.68, green: 0.60, blue: 0.47)
    /// Tertiary / hint text (decorative; use for small caps labels only)
    static let histFaded     = Color(red: 0.44, green: 0.38, blue: 0.29)

    // ── Brand accents ─────────────────────────────────────────
    /// Antique gold – primary accent (≥ 7 : 1 on histBgDeep)
    static let histGold      = Color(red: 0.84, green: 0.67, blue: 0.27)
    /// Sealing-wax red – wrong / danger
    static let histRed       = Color(red: 0.84, green: 0.22, blue: 0.18)
    /// Verdant map-green – correct / success
    static let histGreen     = Color(red: 0.20, green: 0.62, blue: 0.34)

    // ── Structural ───────────────────────────────────────────
    /// Gold separator / border (decorative)
    static let histSeparator = Color(red: 0.84, green: 0.67, blue: 0.27).opacity(0.28)
}
