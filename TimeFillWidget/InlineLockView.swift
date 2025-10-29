//
//  InlineLockView.swift
//  TimeFillWidget
//
//  Lock screen inline countdown widget (single line at top) - Simple text only
//

import SwiftUI
import WidgetKit

// MARK: - Inline Lock Screen Widget View
struct InlineLockView: View {
    let entry: CountdownEntry

    var body: some View {
        Group {
            if let event = entry.event {
                // Simple text format for inline widget (no icons in inline)
                // Show event target date professionally
                if event.isScheduled {
                    if event.startsToday {
                        Text("\(event.name) • Starts in \(event.hoursUntilStart)h • \(event.formattedTargetDate)")
                    } else {
                        Text("\(event.name) • Starts in \(event.daysUntilStart)d • \(event.formattedTargetDate)")
                    }
                } else if entry.isCompletedAtEntry {
                    Text("\(event.name) • Done! • \(event.formattedTargetDate)")
                } else if entry.isInFinalMinuteAtEntry {
                    Text("\(event.name) • \(entry.secondsRemainingAtEntry)s left • \(event.formattedTargetDate)")
                } else if event.isToday {
                    // Hours countdown when < 24 hours remaining
                    Text("\(event.name) • \(event.hoursRemaining)h left • \(event.formattedTargetDate)")
                } else if event.daysRemaining == 1 {
                    Text("\(event.name) • Tomorrow • \(event.formattedTargetDate)")
                } else {
                    Text("\(event.name) • \(event.daysRemaining)d left • \(event.formattedTargetDate)")
                }
            } else {
                // No event
                Text("No countdown")
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Preview
#Preview("Inline Lock", as: .accessoryInline) {
    LockScreenCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
