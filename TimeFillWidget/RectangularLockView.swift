//
//  RectangularLockView.swift
//  TimeFillWidget
//
//  Lock screen rectangular countdown widget - Simple and compliant
//

import SwiftUI
import WidgetKit

// MARK: - Rectangular Lock Screen Widget View
struct RectangularLockView: View {
    let entry: CountdownEntry

    var body: some View {
        ZStack {
            if let event = entry.event {
                // Horizontal layout: icon on left, content on right
                // Match home screen widget design with proper text handling
                HStack(spacing: 8) {
                    // Icon - state-aware like home screen widgets
                    if event.isScheduled {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 24, height: 24)
                    } else if entry.isCompletedAtEntry {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 24, height: 24)
                    } else if entry.isInFinalMinuteAtEntry {
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: event.iconName)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 24, height: 24)
                    }

                    // Content - event name and countdown
                    VStack(alignment: .leading, spacing: 1) {
                        // Event name - smart truncation to prevent "Anal..." issue
                        Text(event.name)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        // Countdown - bold number with unit
                        // Match home screen typography style
                        HStack(spacing: 3) {
                            if event.isScheduled {
                                if event.startsToday {
                                    Text("\(event.hoursUntilStart)")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    Text(event.hoursUntilStart == 1 ? "HR LEFT" : "HRS LEFT")
                                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("\(event.daysUntilStart)")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    Text("STARTS")
                                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                            } else if entry.isCompletedAtEntry {
                                Text("DONE")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            } else if entry.isInFinalMinuteAtEntry {
                                Text("\(entry.secondsRemainingAtEntry)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Text("SEC LEFT")
                                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            } else if event.isToday {
                                Text("\(event.hoursRemaining)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Text(event.hoursRemaining == 1 ? "HR LEFT" : "HRS LEFT")
                                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("\(event.daysRemaining)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Text(event.daysRemaining == 1 ? "DAY LEFT" : "DAYS LEFT")
                                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer(minLength: 0)

                    // Progress indicator - subtle like home widgets
                    if !entry.isCompletedAtEntry {
                        Text("\(Int(event.progress * 100))%")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // No event - clean icon display
                HStack(spacing: 6) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 16, weight: .semibold))
                    Text("No Event")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Preview
#Preview("Rectangular Lock", as: .accessoryRectangular) {
    LockScreenCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
