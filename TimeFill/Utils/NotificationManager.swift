//
//  NotificationManager.swift
//  TimeFill
//
//  Created on 2025-10-06
//

import Foundation
@preconcurrency import UserNotifications
import SwiftData

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var notificationPreferences = NotificationPreferences()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            isAuthorized = granted
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Schedule Notifications

    func scheduleNotifications(for event: CountdownEvent) {
        guard isAuthorized else {
            print("⚠️ Notifications not authorized - cannot schedule")
            return
        }

        print("🔔 Scheduling notifications for event: \(event.name)")

        // Cancel existing notifications for this event
        cancelNotifications(for: event)

        let calendar = Calendar.current
        let now = Date()

        // Schedule notifications based on preferences
        var scheduledDates: [Date] = []

        // For scheduled events, notify when countdown starts
        if event.isScheduled && event.createdDate > now {
            if let startDayMorning = calendar.date(
                bySettingHour: 9,
                minute: 0,
                second: 0,
                of: event.createdDate
            ), startDayMorning > now {
                scheduledDates.append(startDayMorning)
            }
        }

        // On event day
        if notificationPreferences.onEventDay {
            let timeComponents = notificationPreferences.timeComponents(from: notificationPreferences.eventDayTime)
            if let eventDayTime = calendar.date(
                bySettingHour: timeComponents.hour,
                minute: timeComponents.minute,
                second: 0,
                of: event.targetDate
            ), eventDayTime > now {
                scheduledDates.append(eventDayTime)
            }
        }

        // At exact event time (when countdown reaches 0)
        if event.targetDate > now {
            scheduledDates.append(event.targetDate)
        }

        // 1 day before
        if notificationPreferences.oneDayBefore {
            if let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: event.targetDate) {
                let timeComponents = notificationPreferences.timeComponents(from: notificationPreferences.oneDayBeforeTime)
                if let notificationTime = calendar.date(
                    bySettingHour: timeComponents.hour,
                    minute: timeComponents.minute,
                    second: 0,
                    of: oneDayBefore
                ), notificationTime > now {
                    scheduledDates.append(notificationTime)
                }
            }
        }

        // 1 week before
        if notificationPreferences.oneWeekBefore {
            if let oneWeekBefore = calendar.date(byAdding: .day, value: -7, to: event.targetDate) {
                let timeComponents = notificationPreferences.timeComponents(from: notificationPreferences.oneWeekBeforeTime)
                if let notificationTime = calendar.date(
                    bySettingHour: timeComponents.hour,
                    minute: timeComponents.minute,
                    second: 0,
                    of: oneWeekBefore
                ), notificationTime > now {
                    scheduledDates.append(notificationTime)
                }
            }
        }

        // 1 month before
        if notificationPreferences.oneMonthBefore {
            if let oneMonthBefore = calendar.date(byAdding: .month, value: -1, to: event.targetDate) {
                let timeComponents = notificationPreferences.timeComponents(from: notificationPreferences.oneMonthBeforeTime)
                if let notificationTime = calendar.date(
                    bySettingHour: timeComponents.hour,
                    minute: timeComponents.minute,
                    second: 0,
                    of: oneMonthBefore
                ), notificationTime > now {
                    scheduledDates.append(notificationTime)
                }
            }
        }

        // Create notifications for each scheduled date
        for (index, date) in scheduledDates.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Time Fill"

            // Check if this is the countdown start notification (for scheduled events)
            // Use calendar comparison instead of event.isScheduled since that changes over time
            if calendar.isDate(date, inSameDayAs: event.createdDate) && event.createdDate > now {
                content.subtitle = event.name
                content.body = "⏱️ Your countdown begins today!"
            }
            // Check if this is the exact event time (when countdown reaches 0)
            else if calendar.isDate(date, inSameDayAs: event.targetDate) &&
               abs(date.timeIntervalSince(event.targetDate)) < 60 {
                content.subtitle = event.name
                content.body = "🎊 The moment has arrived! Your countdown is complete!"
            }
            else {
                let daysUntil = calendar.dateComponents([.day], from: date, to: event.targetDate).day ?? 0

                if daysUntil == 0 {
                    content.subtitle = event.name
                    content.body = "🎉 Today is the day!"
                } else if daysUntil == 1 {
                    content.subtitle = event.name
                    content.body = "📅 Tomorrow is the big day!"
                } else if daysUntil == 7 {
                    content.subtitle = event.name
                    content.body = "⏰ One week to go!"
                } else if daysUntil >= 28 && daysUntil <= 31 {
                    content.subtitle = event.name
                    content.body = "📆 One month away!"
                } else {
                    content.subtitle = event.name
                    content.body = "\(daysUntil) \(daysUntil == 1 ? "day" : "days") to go"
                }
            }

            content.sound = .default
            content.badge = 1

            let dateComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let identifier = "\(event.id.uuidString)-\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            // Capture necessary values before async closure
            let notificationBody = content.body
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error)")
                } else {
                    print("✅ Scheduled notification for \(date) - \(notificationBody)")
                }
            }
        }
    }

    func scheduleNotifications(for events: [CountdownEvent]) {
        for event in events {
            scheduleNotifications(for: event)
        }
    }

    // MARK: - Cancel Notifications

    func cancelNotifications(for event: CountdownEvent) {
        let identifierPrefix = event.id.uuidString

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests
                .filter { $0.identifier.hasPrefix(identifierPrefix) }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Reschedule All

    func rescheduleAllNotifications(for events: [CountdownEvent]) {
        cancelAllNotifications()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scheduleNotifications(for: events)
        }
    }
}

// MARK: - Notification Preferences

struct NotificationPreferences: Codable {
    var isEnabled: Bool = true
    var onEventDay: Bool = true
    var oneDayBefore: Bool = true
    var oneWeekBefore: Bool = true
    var oneMonthBefore: Bool = false

    // Custom notification times (stored as minutes from midnight, 0-1439)
    var eventDayTime: Int = 540       // 9:00 AM (9 * 60)
    var oneDayBeforeTime: Int = 1080  // 6:00 PM (18 * 60)
    var oneWeekBeforeTime: Int = 1080 // 6:00 PM (18 * 60)
    var oneMonthBeforeTime: Int = 1080 // 6:00 PM (18 * 60)

    enum CodingKeys: String, CodingKey {
        case isEnabled
        case onEventDay
        case oneDayBefore
        case oneWeekBefore
        case oneMonthBefore
        case eventDayTime
        case oneDayBeforeTime
        case oneWeekBeforeTime
        case oneMonthBeforeTime
    }

    // Helper to convert minutes from midnight to Date components
    func timeComponents(from minutes: Int) -> (hour: Int, minute: Int) {
        let hour = minutes / 60
        let minute = minutes % 60
        return (hour, minute)
    }

    // Helper to convert Date to minutes from midnight
    static func minutesFromMidnight(date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}

// MARK: - UserDefaults Extension

extension NotificationPreferences {
    private static let key = "notificationPreferences"

    static func load() -> NotificationPreferences {
        guard let data = UserDefaults.standard.data(forKey: key),
              let preferences = try? JSONDecoder().decode(NotificationPreferences.self, from: data) else {
            return NotificationPreferences()
        }
        return preferences
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: NotificationPreferences.key)
        }
    }
}
