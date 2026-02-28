//
//  DotRingCountdownView.swift
//  TimeFillWidget
//
//  Dot ring countdown widget - circular dot-based progress visualization
//

import SwiftUI
import WidgetKit

// MARK: - Dot Ring Countdown View
struct DotRingCountdownView: View {
    let entry: CountdownEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let event = entry.event {
            Link(destination: URL(string: "timefill://event/\(event.id)")!) {
                countdownContent(event: event)
            }
            .unredacted()
        } else {
            SetupGuideView()
                .unredacted()
        }
    }

    @ViewBuilder
    private func countdownContent(event: WidgetEventData) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#0F0F0F"),
                    Color(hex: "#0A0A0A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [event.color.opacity(0.025), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 160
            )
            .ignoresSafeArea()

            Group {
                switch family {
                case .systemSmall:
                    smallDotRingView(event: event)
                case .systemMedium:
                    mediumDotRingView(event: event)
                case .systemLarge:
                    largeDotRingView(event: event)
                default:
                    smallDotRingView(event: event)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Small Widget Layout
    @ViewBuilder
    private func smallDotRingView(event: WidgetEventData) -> some View {
        VStack(spacing: 0) {
            // Event name at top
            HStack(spacing: 4) {
                eventIcon(event: event, size: 12)
                Text(event.name)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
                .frame(maxHeight: 4)

            // Dot ring with countdown inside
            ZStack {
                DotRingShape(
                    progress: entry.isCompletedAtEntry ? 1.0 : event.progress,
                    color: entry.isInFinalMinuteAtEntry ? .orange : event.color,
                    dotCount: 24,
                    ringSize: 108,
                    dotSize: 6
                )

                // Countdown number + label inside ring
                VStack(spacing: 1) {
                    countdownNumber(event: event, fontSize: 36)
                    countdownLabel(event: event, fontSize: 9)
                }
            }
            .frame(width: 108, height: 108)

            Spacer()
                .frame(maxHeight: 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Medium Widget Layout
    @ViewBuilder
    private func mediumDotRingView(event: WidgetEventData) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 16) {
                // Left side - Dot ring with number inside
                ZStack {
                    DotRingShape(
                        progress: entry.isCompletedAtEntry ? 1.0 : event.progress,
                        color: entry.isInFinalMinuteAtEntry ? .orange : event.color,
                        dotCount: 30,
                        ringSize: 120,
                        dotSize: 6
                    )

                    VStack(spacing: 1) {
                        countdownNumber(event: event, fontSize: 40)
                        countdownLabel(event: event, fontSize: 9)
                    }
                }
                .frame(width: 120, height: 120)
                .frame(maxHeight: .infinity)

                // Right side - Event details
                VStack(alignment: .leading, spacing: 6) {
                    Spacer()

                    // Icon + name
                    HStack(spacing: 6) {
                        eventIcon(event: event, size: 18)
                        Text(event.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .minimumScaleFactor(0.85)
                    }

                    // Target date
                    if !entry.isCompletedAtEntry {
                        Text(event.formattedTargetDate)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#5A5A5A"))
                    }

                    // Progress percentage
                    if !entry.isCompletedAtEntry && !entry.isInFinalMinuteAtEntry {
                        Text("\(Int(event.progress * 100))% complete")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(event.color.opacity(0.45))
                    } else if entry.isCompletedAtEntry {
                        Text("Completed")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(event.color)
                    }

                    Spacer()
                }
                .frame(maxWidth: geometry.size.width - 152)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Large Widget Layout
    @ViewBuilder
    private func largeDotRingView(event: WidgetEventData) -> some View {
        VStack(spacing: 12) {
            // Event name + icon at top
            HStack(spacing: 8) {
                eventIcon(event: event, size: 20)
                Text(event.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                if !entry.isCompletedAtEntry {
                    Text(event.formattedTargetDate)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#5A5A5A"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
                .frame(height: 4)

            // Large dot ring centered
            ZStack {
                DotRingShape(
                    progress: entry.isCompletedAtEntry ? 1.0 : event.progress,
                    color: entry.isInFinalMinuteAtEntry ? .orange : event.color,
                    dotCount: 36,
                    ringSize: 160,
                    dotSize: 8
                )

                VStack(spacing: 2) {
                    countdownNumber(event: event, fontSize: 52)
                    countdownLabel(event: event, fontSize: 11)
                }
            }
            .frame(width: 160, height: 160)

            Spacer()
                .frame(height: 4)

            // Bottom stats row
            HStack(spacing: 0) {
                // Progress
                VStack(spacing: 2) {
                    Text("\(Int(event.progress * 100))%")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(entry.isCompletedAtEntry ? event.color : .white)
                    Text("complete")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#5A5A5A"))
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 1, height: 30)

                VStack(spacing: 2) {
                    Text("\(elapsedDays(event: event))")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(elapsedDays(event: event) == 1 ? "day passed" : "days passed")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#5A5A5A"))
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 1, height: 30)

                VStack(spacing: 2) {
                    if event.isToday && !entry.isCompletedAtEntry {
                        Text("\(event.hoursRemaining)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(event.hoursRemaining == 1 ? "hour left" : "hours left")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#5A5A5A"))
                    } else {
                        Text("\(event.daysRemaining)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(event.daysRemaining == 1 ? "day left" : "days left")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#5A5A5A"))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func elapsedDays(event: WidgetEventData) -> Int {
        let components = Calendar.current.dateComponents([.day], from: event.createdDate, to: Date())
        let totalDays = Calendar.current.dateComponents([.day], from: event.createdDate, to: event.targetDate).day ?? 1
        return min(max(components.day ?? 0, 0), totalDays)
    }

    @ViewBuilder
    private func eventIcon(event: WidgetEventData, size: CGFloat) -> some View {
        if event.isScheduled {
            Image(systemName: "clock.fill")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(event.color)
        } else if entry.isCompletedAtEntry {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(event.color)
        } else if entry.isInFinalMinuteAtEntry {
            Image(systemName: "stopwatch.fill")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.orange)
        } else {
            Image(systemName: event.iconName)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(event.color)
        }
    }

    @ViewBuilder
    private func countdownNumber(event: WidgetEventData, fontSize: CGFloat) -> some View {
        if event.isScheduled {
            if event.startsToday {
                Text("\(event.hoursUntilStart)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Text("\(event.daysUntilStart)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        } else if entry.isCompletedAtEntry {
            Text("DONE")
                .font(.system(size: fontSize * 0.7, weight: .bold, design: .rounded))
                .foregroundStyle(event.color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        } else if entry.isInFinalMinuteAtEntry {
            Text("\(entry.secondsRemainingAtEntry)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        } else if event.isToday {
            Text("\(event.hoursRemaining)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        } else {
            Text("\(event.daysRemaining)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    @ViewBuilder
    private func countdownLabel(event: WidgetEventData, fontSize: CGFloat) -> some View {
        if event.isScheduled {
            if event.startsToday {
                Text(event.hoursUntilStart == 1 ? "HOUR LEFT" : "HOURS LEFT")
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#5A5A5A"))
                    .tracking(1.2)
            } else {
                Text("STARTS IN")
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#5A5A5A"))
                    .tracking(1.2)
            }
        } else if entry.isCompletedAtEntry {
            Text("")
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
        } else if entry.isInFinalMinuteAtEntry {
            Text("SECONDS")
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#5A5A5A"))
                .tracking(1.2)
        } else if event.isToday {
            Text(event.hoursRemaining == 1 ? "HOUR LEFT" : "HOURS LEFT")
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#5A5A5A"))
                .tracking(1.2)
        } else {
            Text(event.daysRemaining == 1 ? "DAY LEFT" : "DAYS LEFT")
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#5A5A5A"))
                .tracking(1.2)
        }
    }
}

// MARK: - Dot Ring Shape Component
struct DotRingShape: View {
    let progress: Double
    let color: Color
    let dotCount: Int
    let ringSize: CGFloat
    let dotSize: CGFloat

    var body: some View {
        let radius = ringSize / 2 - dotSize
        let filledCount = Int(Double(dotCount) * min(max(progress, 0), 1))

        ZStack {
            ForEach(0..<dotCount, id: \.self) { index in
                let angle = (2 * .pi / Double(dotCount)) * Double(index) - .pi / 2
                let x = cos(angle) * Double(radius)
                let y = sin(angle) * Double(radius)
                let isFilled = index < filledCount

                let rampOpacity = isFilled
                    ? (filledCount > 1 ? 0.35 + 0.65 * (Double(index) / Double(filledCount - 1)) : 1.0)
                    : 1.0

                Circle()
                    .fill(isFilled ? color.opacity(rampOpacity) : Color.white.opacity(0.07))
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: x, y: y)

                if isFilled && index == filledCount - 1 {
                    Circle()
                        .stroke(color.opacity(0.5), lineWidth: 1)
                        .frame(width: dotSize + 3, height: dotSize + 3)
                        .offset(x: x, y: y)
                }
            }
        }
        .frame(width: ringSize, height: ringSize)
    }
}

// MARK: - Previews
#Preview("Dot Ring Small", as: .systemSmall) {
    DotRingCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}

#Preview("Dot Ring Medium", as: .systemMedium) {
    DotRingCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}

#Preview("Dot Ring Large", as: .systemLarge) {
    DotRingCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
