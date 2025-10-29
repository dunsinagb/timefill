//
//  CircularLockView.swift
//  TimeFillWidget
//
//  Lock screen circular countdown widget - Apple guidelines compliant
//

import SwiftUI
import WidgetKit

// MARK: - Circular Lock Screen Widget View
struct CircularLockView: View {
    let entry: CountdownEntry

    var body: some View {
        ZStack {
            if let event = entry.event {
                // Use Gauge - Apple's official lock screen circular widget style
                // Match home screen widget design with clean, bold typography
                Gauge(value: event.progress) {
                    // Icon - changes based on state like home screen widgets
                    if event.isScheduled {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14, weight: .semibold))
                    } else if entry.isCompletedAtEntry {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                    } else if entry.isInFinalMinuteAtEntry {
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 14, weight: .semibold))
                    } else {
                        Image(systemName: event.iconName)
                            .font(.system(size: 14, weight: .semibold))
                    }
                } currentValueLabel: {
                    // Bold countdown number - matching home screen typography
                    if event.isScheduled {
                        if event.startsToday {
                            Text("\(event.hoursUntilStart)")
                                .font(.system(.title, design: .rounded, weight: .bold))
                        } else {
                            Text("\(event.daysUntilStart)")
                                .font(.system(.title, design: .rounded, weight: .bold))
                        }
                    } else if entry.isCompletedAtEntry {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                    } else if entry.isInFinalMinuteAtEntry {
                        Text("\(entry.secondsRemainingAtEntry)")
                            .font(.system(.title, design: .rounded, weight: .bold))
                    } else if event.isToday {
                        Text("\(event.hoursRemaining)")
                            .font(.system(.title, design: .rounded, weight: .bold))
                    } else {
                        Text("\(event.daysRemaining)")
                            .font(.system(.title, design: .rounded, weight: .bold))
                    }
                }
                .gaugeStyle(.accessoryCircularCapacity)
            } else {
                // No event - simple icon
                Image(systemName: "hourglass")
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Preview
#Preview("Circular Lock", as: .accessoryCircular) {
    LockScreenCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
