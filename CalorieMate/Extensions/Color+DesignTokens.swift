import SwiftUI

extension Color {

    // MARK: - Primary

    static let cmPrimary = Color(light: .hex(0x1B6B4A), dark: .hex(0x34D399))
    static let cmPrimaryLight = Color(light: .hex(0xE8F5EE), dark: .hex(0x1A3A2A))
    static let cmPrimaryDark = Color(light: .hex(0x0F4A32), dark: .hex(0x6EE7B7))

    // MARK: - Semantic (Macros)

    static let cmProtein = Color(light: .hex(0x3B82F6), dark: .hex(0x60A5FA))
    static let cmFat = Color(light: .hex(0xF59E0B), dark: .hex(0xFBBF24))
    static let cmCarbs = Color(light: .hex(0x8B5CF6), dark: .hex(0xA78BFA))

    // MARK: - Semantic (Status)

    static let cmWarning = Color(light: .hex(0xEAB308), dark: .hex(0xFDE047))
    static let cmDanger = Color(light: .hex(0xEF4444), dark: .hex(0xF87171))
    static let cmSuccess = Color(light: .hex(0x22C55E), dark: .hex(0x4ADE80))

    // MARK: - Text

    static let cmTextPrimary = Color(light: .hex(0x1A1A1A), dark: .hex(0xF5F5F5))
    static let cmTextSecondary = Color(light: .hex(0x666666), dark: .hex(0xA3A3A3))
    static let cmTextTertiary = Color(light: .hex(0x999999), dark: .hex(0x737373))

    // MARK: - Backgrounds

    static let cmBgPrimary = Color(light: .hex(0xFFFFFF), dark: .hex(0x0A0A0A))
    static let cmBgSecondary = Color(light: .hex(0xF5F5F5), dark: .hex(0x171717))
    static let cmBgTertiary = Color(light: .hex(0xEBEBEB), dark: .hex(0x262626))

    // MARK: - Border

    static let cmBorder = Color(light: .hex(0xE5E5E5), dark: .hex(0x333333))
}

// MARK: - Helpers

private extension Color {
    /// Creates an adaptive color that switches between light and dark mode.
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }
}

private extension UIColor {
    /// Creates a UIColor from a hex integer (e.g. 0x1B6B4A).
    static func hex(_ value: UInt) -> UIColor {
        UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255.0,
            green: CGFloat((value >> 8) & 0xFF) / 255.0,
            blue: CGFloat(value & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
