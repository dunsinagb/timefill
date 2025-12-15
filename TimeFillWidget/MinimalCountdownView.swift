//
//  MinimalCountdownView.swift
//  TimeFillWidget
//
//  Pure dark-mode minimal countdown - edge-to-edge centered design
//

import SwiftUI
import WidgetKit

// MARK: - Minimal Countdown Widget View
struct MinimalCountdownView: View {
    let entry: CountdownEntry

    var body: some View {
        if let event = entry.event {
            // Event is configured - show countdown
            // Widget link for deep linking to event detail
            Link(destination: URL(string: "timefill://event/\(event.id)")!) {
                countdownContent(event: event)
                    .unredacted()  // Show full content in gallery and when configured
            }
        } else {
            // No event configured - show setup guide
            // Instructs user to long press and edit widget
            SetupGuideView()
                .unredacted()  // Prevent system placeholder redaction
        }
    }

    @ViewBuilder
    private func countdownContent(event: WidgetEventData) -> some View {
        ZStack {
            // Pure dark background - deep black with subtle gradient for depth
            // Fills entire widget bounds with no padding
            LinearGradient(
                colors: [
                    Color(hex: "#0F0F0F"),  // Slightly lighter top for depth
                    Color(hex: "#0A0A0A")   // Deep black bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Content - vertically centered with optical balance
            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: .infinity)  // Push icon down slightly

                // Event icon - changes based on event state at entry time
                if event.isScheduled {
                    // Scheduled icon for future events
                    Image(systemName: "clock.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 42, height: 42)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 10)
                } else if entry.isCompletedAtEntry {
                    // Checkmark when completed
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 42, height: 42)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 10)
                } else if entry.isInFinalMinuteAtEntry {
                    // Stopwatch in final minute
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(.orange)
                        .frame(width: 42, height: 42)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 10)
                } else {
                    // Regular event icon
                    Image(systemName: event.iconName)
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 42, height: 42)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 10)
                }

                // Large countdown number - changes based on state
                if event.isScheduled {
                    // Show hours if starting within 24 hours, otherwise days
                    if event.startsToday {
                        Text("\(event.hoursUntilStart)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .padding(.bottom, 2)
                    } else {
                        Text("\(event.daysUntilStart)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .padding(.bottom, 2)
                    }
                } else if entry.isCompletedAtEntry {
                    Text("DONE")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(event.color)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 2)
                } else if entry.isInFinalMinuteAtEntry {
                    Text("\(entry.secondsRemainingAtEntry)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 2)
                } else if event.isToday {
                    Text("\(event.hoursRemaining)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 2)
                } else {
                    Text("\(event.daysRemaining)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 2)
                }

                // Label - changes based on state
                if event.isScheduled {
                    // Show appropriate label for scheduled events
                    if event.startsToday {
                        Text(event.hoursUntilStart == 1 ? "HOUR LEFT" : "HOURS LEFT")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#8E8E8E"))
                            .tracking(1.5)
                            .textCase(.uppercase)
                    } else {
                        Text("STARTS IN")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#8E8E8E"))
                            .tracking(1.5)
                            .textCase(.uppercase)
                    }
                } else if entry.isCompletedAtEntry {
                    Text("")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .padding(.bottom, 2)
                } else if entry.isInFinalMinuteAtEntry {
                    Text("SECONDS LEFT")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8E8E8E"))
                        .tracking(1.5)
                        .textCase(.uppercase)
                } else if event.isToday {
                    Text(event.hoursRemaining == 1 ? "HOUR LEFT" : "HOURS LEFT")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8E8E8E"))
                        .tracking(1.5)
                        .textCase(.uppercase)
                } else {
                    Text(event.daysRemaining == 1 ? "DAY LEFT" : "DAYS LEFT")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8E8E8E"))
                        .tracking(1.5)
                        .textCase(.uppercase)
                }

                // Battery indicator - compact visualization
                if !entry.isCompletedAtEntry {
                    WidgetBatteryView(progress: event.progress, color: event.color)
                        .padding(.top, 5)
                }

                Spacer()
                    .frame(maxHeight: .infinity)

                // Event title with smart truncation
                // Hide if too long to maintain clean centered look
                if event.name.count <= 18 {
                    Text(event.name)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 6)
                        .padding(.bottom, 8)
                } else {
                    // Title too long - hide it, icon + number is enough
                    Spacer()
                        .frame(height: 8)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .preferredColorScheme(.dark)  // Force dark mode always
    }
}

// MARK: - Widget Battery View
/// Compact battery indicator for widgets - shows progress in battery-style visualization
struct WidgetBatteryView: View {
    let progress: Double
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            // Battery body
            ZStack(alignment: .leading) {
                // Background outline
                RoundedRectangle(cornerRadius: 2.5)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 70, height: 20)

                // Fill - animated progress
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: max(64 * progress, 0), height: 14)
                    .padding(.leading, 3)
            }
            .frame(width: 70, height: 20)

            // Battery tip
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.white.opacity(0.3))
                .frame(width: 3, height: 10)
        }
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    MinimalCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
