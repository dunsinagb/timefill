//
//  CountdownEvent.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import Foundation
import SwiftData

@Model
final class CountdownEvent {
    var id: UUID
    var name: String
    var targetDate: Date
    var createdDate: Date  // Countdown start date (can be past/now/future)
    var addedToAppDate: Date = Date()  // When event was actually created in the app (default to now)
    var colorHex: String
    var iconName: String
    var repeatType: String = "Never"  // Never, Daily, Weekly, Monthly, Yearly
    var repeatInterval: Int = 1  // Every X days/weeks/months/years
    var yearlyRepeatStyle: String = "fixedDate"  // fixedDate or relativeWeekday (for Yearly only)
    var isRepeatOccurrence: Bool = false  // True if auto-created from repeat

    init(name: String, targetDate: Date, colorHex: String = "#36C2FF", iconName: String = "calendar", repeatType: String = "Never", repeatInterval: Int = 1, yearlyRepeatStyle: String = "fixedDate", isRepeatOccurrence: Bool = false) {
        self.id = UUID()
        self.name = name
        self.targetDate = targetDate
        self.createdDate = Date()
        self.addedToAppDate = Date()  // Always set to now when created
        self.colorHex = colorHex
        self.iconName = iconName
        self.repeatType = repeatType
        self.repeatInterval = repeatInterval
        self.yearlyRepeatStyle = yearlyRepeatStyle
        self.isRepeatOccurrence = isRepeatOccurrence
    }

    // Calculate days remaining (using actual time, matching detail view countdown)
    var daysRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: targetDate)
        return max(components.day ?? 0, 0)
    }

    // Calculate hours remaining (beyond days)
    var hoursRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: targetDate)
        return max(components.hour ?? 0, 0)
    }

    // Calculate minutes remaining (beyond hours)
    var minutesRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: targetDate)
        return max(components.minute ?? 0, 0)
    }

    // Calculate seconds remaining (beyond minutes)
    var secondsRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: targetDate)
        return max(components.second ?? 0, 0)
    }

    // Check if countdown is scheduled for future
    var isScheduled: Bool {
        Date() < createdDate
    }

    // Days until countdown starts (for scheduled events, using actual time)
    var daysUntilStart: Int {
        guard isScheduled else { return 0 }
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: createdDate)
        return max(components.day ?? 0, 0)
    }

    // Hours until countdown starts (total hours, for scheduled events)
    var hoursUntilStart: Int {
        guard isScheduled else { return 0 }
        let interval = createdDate.timeIntervalSince(Date())
        return max(Int(interval / 3600), 0)
    }

    // Check if countdown starts today (within 24 hours)
    var startsToday: Bool {
        guard isScheduled else { return false }
        return hoursUntilStart < 24 && hoursUntilStart >= 0
    }

    // Calculate progress percentage (0.0 to 1.0)
    var progress: Double {
        // If scheduled, progress is 0
        guard !isScheduled else { return 0.0 }

        let totalTime = targetDate.timeIntervalSince(createdDate)
        let elapsedTime = Date().timeIntervalSince(createdDate)
        let progress = min(max(elapsedTime / totalTime, 0.0), 1.0)
        return progress
    }

    // Check if event is completed
    var isCompleted: Bool {
        Date() >= targetDate
    }

    // Check if event repeats
    var repeats: Bool {
        repeatType != "Never"
    }

    // Calculate next occurrence date for repeating events
    func nextOccurrenceDate(after date: Date) -> Date? {
        guard repeats else { return nil }

        let calendar = Calendar.current
        switch repeatType {
        case "Daily":
            // Repeats every N days from the date
            return calendar.date(byAdding: .day, value: repeatInterval, to: date)

        case "Weekly":
            // Repeats every N weeks, preserving the day of the week
            return calendar.date(byAdding: .weekOfYear, value: repeatInterval, to: date)

        case "Monthly":
            // Repeats every N months, preserving the day of the month
            return calendar.date(byAdding: .month, value: repeatInterval, to: date)

        case "Yearly":
            if yearlyRepeatStyle == "relativeWeekday" {
                // Relative weekday: e.g., "First Sunday of November"
                // Get the current date's weekday and its position in the month
                let weekday = calendar.component(.weekday, from: date)
                let month = calendar.component(.month, from: date)

                // Calculate which occurrence of the weekday this is (1st, 2nd, 3rd, 4th, or 5th)
                let dayOfMonth = calendar.component(.day, from: date)
                let weekdayOrdinal = (dayOfMonth - 1) / 7 + 1

                // Start from the year after adding repeatInterval years
                guard var targetYear = calendar.date(byAdding: .year, value: repeatInterval, to: date) else {
                    return nil
                }

                // Get the first day of the target month
                var components = calendar.dateComponents([.year, .month], from: targetYear)
                components.month = month
                components.day = 1

                guard let firstOfMonth = calendar.date(from: components) else {
                    return nil
                }

                // Find the nth occurrence of the weekday in that month
                var daysToAdd = 0
                let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

                // Calculate days to the first occurrence of the target weekday
                if weekday >= firstWeekday {
                    daysToAdd = weekday - firstWeekday
                } else {
                    daysToAdd = 7 - firstWeekday + weekday
                }

                // Add weeks to get to the nth occurrence
                daysToAdd += (weekdayOrdinal - 1) * 7

                return calendar.date(byAdding: .day, value: daysToAdd, to: firstOfMonth)
            } else {
                // Fixed date: e.g., "November 2nd"
                // Simply add years, preserving month and day
                return calendar.date(byAdding: .year, value: repeatInterval, to: date)
            }

        default:
            return nil
        }
    }
}
