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
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 48, height: 48)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 12)
                } else if entry.isCompletedAtEntry {
                    // Checkmark when completed
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 48, height: 48)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 12)
                } else if entry.isInFinalMinuteAtEntry {
                    // Stopwatch in final minute
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.orange)
                        .frame(width: 48, height: 48)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 12)
                } else {
                    // Regular event icon
                    Image(systemName: event.iconName)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 48, height: 48)
                        .minimumScaleFactor(0.8)
                        .padding(.bottom, 12)
                }

                // Large countdown number - changes based on state
                if event.isScheduled {
                    Text("\(event.daysUntilStart)")
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 4)
                } else if entry.isCompletedAtEntry {
                    Text("DONE")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(event.color)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 4)
                } else if entry.isInFinalMinuteAtEntry {
                    Text("\(entry.secondsRemainingAtEntry)")
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 4)
                } else {
                    Text("\(event.daysRemaining)")
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.bottom, 4)
                }

                // Label - changes based on state
                if event.isScheduled {
                    Text("STARTS IN")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8E8E8E"))
                        .tracking(1.8)
                        .textCase(.uppercase)
                } else if entry.isCompletedAtEntry {
                    Text("")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .padding(.bottom, 4)
                } else if entry.isInFinalMinuteAtEntry {
                    Text("SECONDS")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8E8E8E"))
                        .tracking(1.8)
                        .textCase(.uppercase)
                } else {
                    Text(event.daysRemaining == 1 ? "DAY" : "DAYS")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8E8E8E"))
                        .tracking(1.8)
                        .textCase(.uppercase)
                }

                Spacer()
                    .frame(maxHeight: .infinity)

                // Event title with smart truncation
                // Hide if too long to maintain clean centered look
                if event.name.count <= 22 {
                    Text(event.name)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 12)
                } else {
                    // Title too long - hide it, icon + number is enough
                    Spacer()
                        .frame(height: 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(.dark)  // Force dark mode always
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    MinimalCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
