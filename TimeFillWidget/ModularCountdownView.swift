//
//  ModularCountdownView.swift
//  TimeFillWidget
//
//  Pure dark-mode modular countdown - data-rich edge-to-edge layout
//

import SwiftUI
import WidgetKit

// MARK: - Modular Countdown Widget View
struct ModularCountdownView: View {
    let entry: CountdownEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let event = entry.event {
            // Event is configured - show countdown
            // Widget link for deep linking to event detail
            Link(destination: URL(string: "timefill://event/\(event.id)")!) {
                countdownContent(event: event)
            }
            .unredacted()  // Show full content in gallery and when configured
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
            // Pure dark background - consistent deep black gradient
            // Edge-to-edge fill with no margins
            LinearGradient(
                colors: [
                    Color(hex: "#0F0F0F"),  // Subtle top highlight
                    Color(hex: "#0A0A0A")   // Deep black base
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Layout varies by widget size
            Group {
                switch family {
                case .systemSmall:
                    smallModularView(event: event)
                case .systemMedium:
                    mediumModularView(event: event)
                default:
                    smallModularView(event: event)
                }
            }
        }
        .preferredColorScheme(.dark)  // Force dark mode always
    }

    // MARK: - Small Widget Layout
    /// Compact layout with title at top, icon + number in center
    @ViewBuilder
    private func smallModularView(event: WidgetEventData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event title at top - truncate if too long
            if event.name.count <= 18 {
                Text(event.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                // Show first word only if too long
                Text(event.name.components(separatedBy: " ").first ?? event.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()

            // Icon and countdown - horizontally aligned in center
            HStack(alignment: .center, spacing: 12) {
                // Icon - changes based on event state at entry time
                if entry.isCompletedAtEntry {
                    // Checkmark when completed
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 44, height: 44)
                        .minimumScaleFactor(0.8)
                } else if entry.isInFinalMinuteAtEntry {
                    // Stopwatch in final minute
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(.orange)
                        .frame(width: 44, height: 44)
                        .minimumScaleFactor(0.8)
                } else {
                    // Regular event icon
                    Image(systemName: event.iconName)
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(event.color)
                        .frame(width: 44, height: 44)
                        .minimumScaleFactor(0.8)
                }

                // Countdown number + label
                VStack(alignment: .center, spacing: 2) {
                    // Large number - shows seconds in final minute
                    if entry.isCompletedAtEntry {
                        Text("DONE")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(event.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    } else if entry.isInFinalMinuteAtEntry {
                        Text("\(entry.secondsRemainingAtEntry)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    } else {
                        Text("\(event.daysRemaining)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    // Label - changes based on state
                    if entry.isCompletedAtEntry {
                        Text("")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    } else if entry.isInFinalMinuteAtEntry {
                        Text("SECONDS")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#8E8E8E"))
                            .tracking(1.5)
                            .textCase(.uppercase)
                    } else {
                        Text(event.daysRemaining == 1 ? "DAY" : "DAYS")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#8E8E8E"))
                            .tracking(1.5)
                            .textCase(.uppercase)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Medium Widget Layout
    /// Rectangular layout with icon on left, content on right
    @ViewBuilder
    private func mediumModularView(event: WidgetEventData) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 16) {
                // Left side - Large icon centered vertically (changes based on state)
                VStack {
                    Spacer()
                    if entry.isCompletedAtEntry {
                        // Checkmark when completed
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundStyle(event.color)
                            .frame(width: 56, height: 56)
                            .minimumScaleFactor(0.8)
                    } else if entry.isInFinalMinuteAtEntry {
                        // Stopwatch in final minute
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundStyle(.orange)
                            .frame(width: 56, height: 56)
                            .minimumScaleFactor(0.8)
                    } else {
                        // Regular event icon
                        Image(systemName: event.iconName)
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundStyle(event.color)
                            .frame(width: 56, height: 56)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer()
                }
                .frame(width: 70)

                // Right side - Event info with vertical centering
                VStack(alignment: .leading, spacing: 0) {
                    // Event title - allow 2 lines for medium widgets
                    Text(event.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    // Countdown number with progress percentage
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        // Large countdown number - changes based on state
                        if entry.isCompletedAtEntry {
                            Text("DONE")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(event.color)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        } else if entry.isInFinalMinuteAtEntry {
                            Text("\(entry.secondsRemainingAtEntry)")
                                .font(.system(size: 68, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        } else {
                            Text("\(event.daysRemaining)")
                                .font(.system(size: 68, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }

                        // Label + progress aligned with number baseline
                        VStack(alignment: .leading, spacing: 3) {
                            // Label - changes based on state
                            if entry.isCompletedAtEntry {
                                Text("100%")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(event.color)
                                    .tracking(1.6)
                            } else if entry.isInFinalMinuteAtEntry {
                                Text("SECONDS")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color(hex: "#8E8E8E"))
                                    .tracking(1.6)
                                    .textCase(.uppercase)
                            } else {
                                Text(event.daysRemaining == 1 ? "DAY" : "DAYS")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color(hex: "#8E8E8E"))
                                    .tracking(1.6)
                                    .textCase(.uppercase)
                            }

                            // Progress percentage - only show when not in final minute or completed
                            if !entry.isInFinalMinuteAtEntry && !entry.isCompletedAtEntry {
                                Text("\(Int(event.progress * 100))%")
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color(hex: "#6E6E6E"))
                            }
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: geometry.size.width - 102)  // Total width minus icon (70) and spacing/padding (32)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    ModularCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}

#Preview(as: .systemMedium) {
    ModularCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
