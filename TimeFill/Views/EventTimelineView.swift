//
//  EventTimelineView.swift
//  TimeFill
//
//  Created on 2025-10-06
//  Film-inspired timeline visualization
//

import SwiftUI
import SwiftData

struct EventTimelineView: View {
    @Query private var allEvents: [CountdownEvent]
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Sort events by target date
    private var sortedEvents: [CountdownEvent] {
        allEvents.sorted { $0.targetDate < $1.targetDate }
    }

    // Get only upcoming events (future events)
    private var upcomingEvents: [CountdownEvent] {
        sortedEvents.filter { $0.targetDate >= currentTime }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.timeFillDarkBg
                    .ignoresSafeArea()

                if upcomingEvents.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "film")
                            .font(.system(size: 64))
                            .foregroundStyle(.gray)

                        Text("No frames yet")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text("Add events to build your timeline")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Film perforations at top
                            FilmPerforations()
                                .padding(.top, 8)

                            // Today marker - special film frame
                            TodayFilmFrame(currentTime: currentTime)
                                .padding(.vertical, 20)

                            // Days between now and first event
                            if let firstEvent = upcomingEvents.first {
                                let daysUntil = daysBetween(from: currentTime, to: firstEvent.targetDate)
                                DaysSeparator(days: daysUntil)
                                    .padding(.vertical, 16)
                            }

                            // Upcoming events as film frames with day separators
                            ForEach(Array(upcomingEvents.enumerated()), id: \.element.id) { index, event in
                                FilmFrameEventRow(
                                    event: event,
                                    currentTime: currentTime
                                )
                                .padding(.vertical, 8)

                                // Days between this event and next
                                if index < upcomingEvents.count - 1 {
                                    let nextEvent = upcomingEvents[index + 1]
                                    let daysBetween = daysBetween(from: event.targetDate, to: nextEvent.targetDate)
                                    DaysSeparator(days: daysBetween)
                                        .padding(.vertical, 16)
                                }
                            }

                            // Film perforations at bottom
                            FilmPerforations()
                                .padding(.top, 20)
                                .padding(.bottom, 24)
                        }
                        .id("\(upcomingEvents.count)-\(Calendar.current.startOfDay(for: currentTime))")
                    }
                }
            }
            .navigationBarHidden(true)
            .onReceive(timer) { time in
                currentTime = time
            }
        }
        .preferredColorScheme(.dark)
    }

    private func daysBetween(from: Date, to: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: from, to: to)
        return max(components.day ?? 0, 0)
    }
}

// Film perforations decoration
struct FilmPerforations: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<8, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 8, height: 12)
            }
        }
    }
}

// Days separator between events
struct DaysSeparator: View {
    let days: Int

    var body: some View {
        HStack(spacing: 12) {
            // Left perforation
            VStack(spacing: 6) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 6, height: 8)
                }
            }

            // Days indicator
            VStack(spacing: 4) {
                Text("\(days)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))

                Text(days == 1 ? "day" : "days")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.gray)
                    .textCase(.uppercase)
                    .tracking(1)
            }

            // Right perforation
            VStack(spacing: 6) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 6, height: 8)
                }
            }
        }
    }
}

// Today marker as special film frame
struct TodayFilmFrame: View {
    let currentTime: Date

    var body: some View {
        VStack(spacing: 0) {
            // Film holes on sides
            HStack(spacing: 0) {
                // Left perforations
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.timeFillCyan.opacity(0.3))
                            .frame(width: 8, height: 12)
                    }
                }

                // Center content - TODAY frame
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "viewfinder.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.timeFillCyan)

                        Text("NOW")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.black)
                            .foregroundStyle(Color.timeFillCyan)
                            .tracking(2)
                    }

                    Text(currentTime, format: .dateTime.month().day().year())
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.timeFillCyan.opacity(0.2),
                                    Color.timeFillCyan.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.timeFillCyan.opacity(0.4), lineWidth: 2)
                )

                // Right perforations
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.timeFillCyan.opacity(0.3))
                            .frame(width: 8, height: 12)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// Simplified film frame for events
struct FilmFrameEventRow: View {
    @Bindable var event: CountdownEvent
    let currentTime: Date

    var body: some View {
        HStack(spacing: 0) {
            // Left perforations
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 8, height: 12)
                }
            }

            // Film frame content - simplified
            VStack(spacing: 12) {
                // Event icon
                ZStack {
                    Circle()
                        .fill(Color(hex: event.colorHex).opacity(0.3))
                        .frame(width: 48, height: 48)

                    Image(systemName: event.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: event.colorHex))
                }

                // Event name - centered
                Text(event.name)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: event.colorHex).opacity(0.3), lineWidth: 1.5)
            )

            // Right perforations
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 8, height: 12)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CountdownEvent.self, configurations: config)

    // Add sample events
    let event1 = CountdownEvent(
        name: "Wifey bday",
        targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
        colorHex: "#36C2FF",
        iconName: "birthday.cake.fill"
    )

    let event2 = CountdownEvent(
        name: "Trip to Paris",
        targetDate: Calendar.current.date(byAdding: .day, value: 60, to: Date())!,
        colorHex: "#FF006E",
        iconName: "airplane.departure"
    )

    let event3 = CountdownEvent(
        name: "Anniversary",
        targetDate: Calendar.current.date(byAdding: .day, value: 90, to: Date())!,
        colorHex: "#8338EC",
        iconName: "heart.fill"
    )

    container.mainContext.insert(event1)
    container.mainContext.insert(event2)
    container.mainContext.insert(event3)

    return EventTimelineView()
        .modelContainer(container)
}
