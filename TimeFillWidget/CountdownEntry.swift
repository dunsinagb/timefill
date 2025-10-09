//
//  CountdownEntry.swift
//  TimeFillWidget
//
//  Created on 2025-10-07
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
/// Represents a single point in time for the widget timeline
struct CountdownEntry: TimelineEntry {
    let date: Date
    let event: WidgetEventData?

    // Calculate seconds remaining at this specific entry's date
    var secondsRemainingAtEntry: Int {
        guard let event = event else { return 0 }
        let remaining = event.targetDate.timeIntervalSince(date)
        return max(Int(remaining), 0)
    }

    // Check if in final minute at this entry's date
    var isInFinalMinuteAtEntry: Bool {
        guard let event = event else { return false }
        let remaining = event.targetDate.timeIntervalSince(date)
        return remaining > 0 && remaining <= 60
    }

    // Check if completed at this entry's date
    var isCompletedAtEntry: Bool {
        guard let event = event else { return false }
        return date >= event.targetDate
    }
}

// MARK: - Widget Event Data
/// Simplified event data structure for widgets (no SwiftData dependency)
struct WidgetEventData {
    let id: String  // Event ID for deep linking
    let name: String
    let targetDate: Date
    let createdDate: Date
    let colorHex: String
    let iconName: String

    // Calculate days remaining
    var daysRemaining: Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: targetDate)
        return max(components.day ?? 0, 0)
    }

    // Calculate progress (0.0 to 1.0)
    var progress: Double {
        let totalTime = targetDate.timeIntervalSince(createdDate)
        let elapsedTime = Date().timeIntervalSince(createdDate)
        return min(max(elapsedTime / totalTime, 0.0), 1.0)
    }

    // Check if completed
    var isCompleted: Bool {
        Date() >= targetDate
    }

    // Check if in final minute (60 seconds or less remaining)
    var isInFinalMinute: Bool {
        let remaining = targetDate.timeIntervalSince(Date())
        return remaining > 0 && remaining <= 60
    }

    // Get seconds remaining (for final minute countdown)
    var secondsRemaining: Int {
        let remaining = targetDate.timeIntervalSince(Date())
        return max(Int(remaining), 0)
    }

    // Get color from hex
    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Sample Data for Previews
extension WidgetEventData {
    /// Gallery preview sample - shown in widget picker before adding to home screen
    static var sample: WidgetEventData {
        WidgetEventData(
            id: "gallery-preview",
            name: "My Birthday",
            targetDate: Calendar.current.date(byAdding: .day, value: 45, to: Date())!,
            createdDate: Date(),
            colorHex: "#EED98C",  // Muted gold to match app theme
            iconName: "gift.fill"
        )
    }

    static var nearFuture: WidgetEventData {
        WidgetEventData(
            id: "preview-2",
            name: "Vacation",
            targetDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            createdDate: Date(),
            colorHex: "#EED98C",
            iconName: "airplane"
        )
    }
}

// MARK: - Color Extension for Hex Support
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
            (a, r, g, b) = (255, 0, 0, 0)
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
