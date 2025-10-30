//
//  ColorExtensions.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI
import UIKit

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
        ColorTheme(hex: "#D4C4E4", name: "Purple")
    ]
}

// MARK: - Color to Hex Extension
extension Color {
    func toHex() -> String {
        // Convert SwiftUI Color to UIColor, then extract RGB components
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
        return String(format: "#%06X", rgb)
    }
}

// MARK: - Native iOS Color Picker Wrapper
// Uses hidden UIViewController to present color picker properly
struct ColorPickerWrapper: UIViewControllerRepresentable {
    @Binding var selectedColor: Color
    @Binding var isPresented: Bool
    let onColorSelected: (Color) -> Void

    func makeUIViewController(context: Context) -> WrapperViewController {
        return WrapperViewController()
    }

    func updateUIViewController(_ uiViewController: WrapperViewController, context: Context) {
        // Present picker when isPresented becomes true
        if isPresented && !context.coordinator.isPresenting {
            context.coordinator.isPresenting = true

            let picker = UIColorPickerViewController()
            picker.selectedColor = UIColor(selectedColor)
            picker.supportsAlpha = false
            picker.delegate = context.coordinator

            // Configure sheet presentation for 580pt height
            if let sheet = picker.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in 580 })]
                sheet.prefersGrabberVisible = true
            }

            // Present on next run loop to avoid timing issues
            DispatchQueue.main.async {
                uiViewController.present(picker, animated: true)
            }
        }
        // Dismiss picker when isPresented becomes false
        else if !isPresented && context.coordinator.isPresenting {
            context.coordinator.isPresenting = false

            DispatchQueue.main.async {
                uiViewController.presentedViewController?.dismiss(animated: true)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // Wrapper view controller - empty, just for presenting
    class WrapperViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = false
        }
    }

    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        let parent: ColorPickerWrapper
        var isPresenting = false

        init(parent: ColorPickerWrapper) {
            self.parent = parent
        }

        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            // User dismissed - update state but DON'T dismiss parent view
            DispatchQueue.main.async {
                self.parent.isPresented = false
            }
        }

        func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            // Update color on main thread
            DispatchQueue.main.async {
                self.parent.selectedColor = Color(color)
                if !continuously {
                    self.parent.onColorSelected(Color(color))
                }
            }
        }
    }
}
