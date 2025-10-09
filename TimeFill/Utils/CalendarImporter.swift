//
//  CalendarImporter.swift
//  TimeFill
//
//  Created on 2025-10-06
//  Import events from system calendar
//

import Foundation
import EventKit
import SwiftData

@MainActor
class CalendarImporter: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var isAuthorized = false
    @Published var isImporting = false
    @Published var importError: String?

    init() {
        // Check current authorization status
        checkAuthorizationStatus()
    }

    // Check current authorization status
    func checkAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = (status == .fullAccess || status == .authorized)
    }

    // Request calendar access
    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            isAuthorized = granted
            return granted
        } catch {
            importError = "Calendar access denied"
            return false
        }
    }

    // Get upcoming calendar events
    func getUpcomingEvents(months: Int = 12) -> [EKEvent] {
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .month, value: months, to: startDate) ?? startDate

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)

        // Return ALL events - let user see everything
        return events
    }

    // Import selected events into TimeFill
    func importEvents(_ ekEvents: [EKEvent], into modelContext: ModelContext) {
        isImporting = true

        var importedEvents: [CountdownEvent] = []
        for ekEvent in ekEvents {
            let countdown = CountdownEvent(
                name: ekEvent.title ?? "Untitled Event",
                targetDate: ekEvent.startDate,
                colorHex: getColorForEvent(ekEvent),
                iconName: getIconForEvent(ekEvent)
            )
            countdown.createdDate = Date()
            modelContext.insert(countdown)
            importedEvents.append(countdown)
        }

        // Schedule notifications for all imported events
        Task {
            await NotificationManager.shared.scheduleNotifications(for: importedEvents)
        }

        isImporting = false
    }

    // Get appropriate color based on calendar or event type
    private func getColorForEvent(_ event: EKEvent) -> String {
        // Use calendar color if available
        if let calendarColor = event.calendar.cgColor {
            return colorToHex(calendarColor)
        }

        // Default colors based on event title keywords
        let title = event.title?.lowercased() ?? ""
        if title.contains("birthday") || title.contains("bday") {
            return "#36C2FF" // Cyan
        } else if title.contains("wedding") || title.contains("anniversary") {
            return "#FF006E" // Pink
        } else if title.contains("trip") || title.contains("vacation") || title.contains("travel") {
            return "#8338EC" // Purple
        } else if title.contains("meeting") || title.contains("work") {
            return "#FB5607" // Orange
        } else {
            return "#36C2FF" // Default cyan
        }
    }

    // Get appropriate icon based on event title
    private func getIconForEvent(_ event: EKEvent) -> String {
        let title = event.title?.lowercased() ?? ""

        // Birthday/celebration
        if title.contains("birthday") || title.contains("bday") {
            return "birthday.cake.fill"
        } else if title.contains("party") {
            return "party.popper.fill"
        }

        // Love/relationships
        else if title.contains("wedding") {
            return "heart.fill"
        } else if title.contains("anniversary") {
            return "heart.circle.fill"
        } else if title.contains("date") {
            return "heart.fill"
        }

        // Travel
        else if title.contains("flight") || title.contains("fly") {
            return "airplane.departure"
        } else if title.contains("trip") || title.contains("vacation") || title.contains("travel") {
            return "suitcase.fill"
        } else if title.contains("hotel") {
            return "bed.double.fill"
        }

        // Work/career
        else if title.contains("meeting") || title.contains("conference") {
            return "person.2.fill"
        } else if title.contains("deadline") || title.contains("due") {
            return "clock.fill"
        } else if title.contains("presentation") {
            return "presentation.fill"
        }

        // Health
        else if title.contains("doctor") || title.contains("appointment") {
            return "cross.fill"
        } else if title.contains("dentist") {
            return "cross.case.fill"
        }

        // Events/entertainment
        else if title.contains("concert") || title.contains("show") {
            return "music.note"
        } else if title.contains("movie") {
            return "film.fill"
        } else if title.contains("game") || title.contains("match") {
            return "sportscourt.fill"
        }

        // Default
        else {
            return "calendar.badge.clock"
        }
    }

    // Convert CGColor to hex string
    private func colorToHex(_ cgColor: CGColor) -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#36C2FF"
        }

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
