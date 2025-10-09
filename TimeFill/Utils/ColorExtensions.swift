//
//  ColorExtensions.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Predefined color themes
extension Color {
    static let timeFillCyan = Color(hex: "#36C2FF")  // App icon primary color
    static let timeFillPurple = Color(hex: "#9B89FF")
    static let timeFillYellow = Color(hex: "#F2C94C")
    static let timeFillPink = Color(hex: "#FF8CB4")
    static let timeFillGreen = Color(hex: "#6FCF97")
    static let timeFillOrange = Color(hex: "#FF9F66")

    static let timeFillDarkBg = Color(hex: "#101218")
    static let timeFillLightBg = Color(hex: "#F7F7F8")
}

struct ColorTheme: Identifiable {
    let id = UUID()
    let hex: String
    let name: String

    var color: Color {
        Color(hex: hex)
    }

    static let themes: [ColorTheme] = [
        ColorTheme(hex: "#36C2FF", name: "Cyan"),
        ColorTheme(hex: "#E0B3FF", name: "Lavender"),
        ColorTheme(hex: "#B4E4CE", name: "Mint"),
        ColorTheme(hex: "#FFB4B4", name: "Rose"),
        ColorTheme(hex: "#FFD4E5", name: "Pink"),
        ColorTheme(hex: "#FFF4B4", name: "Yellow"),
        ColorTheme(hex: "#B4D4E4", name: "Sky"),
        ColorTheme(hex: "#D4C4E4", name: "Purple"),
        ColorTheme(hex: "#808080", name: "Gray")
    ]
}
