//
//  LockScreenCountdownWidget.swift
//  TimeFillWidget
//
//  Lock screen countdown widget definition - Simple and reliable
//

import WidgetKit
import SwiftUI

// MARK: - Lock Screen Countdown Widget
/// Universal lock screen widget - automatically shows next event
struct LockScreenCountdownWidget: Widget {
    let kind: String = "LockScreenCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: SimpleLockScreenProvider()
        ) { entry in
            LockScreenCountdownView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("Shows your next upcoming event.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Adaptive Lock Screen View
/// Automatically switches between circular, rectangular, and inline based on widget family
struct LockScreenCountdownView: View {
    let entry: CountdownEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularLockView(entry: entry)
        case .accessoryRectangular:
            RectangularLockView(entry: entry)
        case .accessoryInline:
            InlineLockView(entry: entry)
        default:
            // Fallback for unsupported families
            Text("Unsupported")
        }
    }
}

// MARK: - Previews
#Preview("Circular", as: .accessoryCircular) {
    LockScreenCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    LockScreenCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}

#Preview("Inline", as: .accessoryInline) {
    LockScreenCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
