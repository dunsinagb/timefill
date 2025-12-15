//
//  EventRepeatManager.swift
//  TimeFill
//
//  Created on 2025-11-03
//  Manages automatic repeat logic for countdown events
//

import Foundation
import SwiftData

/// Manages automatic repeat behavior for countdown events
@MainActor
class EventRepeatManager {
    static let shared = EventRepeatManager()

    // Track recently reset events to prevent duplicate processing
    private var recentlyResetEventIDs: Set<UUID> = []
    private var lastResetTime: Date = Date.distantPast

    private init() {}

    // MARK: - Public Interface

    /// Checks all events and resets any completed repeating events
    /// Call this on app launch and when returning from background
    func updateRepeatingEvents(context: ModelContext) {
        let descriptor = FetchDescriptor<CountdownEvent>()

        guard let allEvents = try? context.fetch(descriptor) else {
            print("⚠️ EventRepeatManager: Failed to fetch events")
            return
        }

        // Process completed repeating events
        for event in allEvents {
            handleRepeatLogic(for: event, context: context)
        }

        // Save changes
        try? context.save()
    }

    /// Handles repeat logic for a single event
    /// Returns true if event was reset, false otherwise
    @discardableResult
    func handleRepeatLogic(for event: CountdownEvent, context: ModelContext) -> Bool {
        // Only process events that:
        // 1. Have repeat enabled
        // 2. Have completed the 2-minute count-up phase
        guard event.shouldResetRepeat else {
            return false
        }

        // Clear recent reset tracking if it's been more than 5 seconds since last reset
        let now = Date()
        if now.timeIntervalSince(lastResetTime) > 5 {
            recentlyResetEventIDs.removeAll()
        }

        // Skip if this event was recently reset (prevents duplicate processing)
        if recentlyResetEventIDs.contains(event.id) {
            print("⏭️ EventRepeatManager: Skipping '\(event.name)' - recently reset")
            return false
        }

        // Calculate next occurrence date
        guard let nextDate = event.nextOccurrenceDate(after: event.targetDate) else {
            print("⚠️ EventRepeatManager: Failed to calculate next occurrence for \(event.name)")
            return false
        }

        print("🔄 EventRepeatManager: Resetting '\(event.name)' from \(event.targetDate) to \(nextDate)")

        // Reset the event
        resetEvent(event, to: nextDate)

        // Track this reset
        recentlyResetEventIDs.insert(event.id)
        lastResetTime = now

        // Reschedule notifications
        NotificationManager.shared.scheduleNotifications(for: event)

        // Update widget data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateWidgetData(context: context)
        }

        return true
    }

    // MARK: - Private Helpers

    /// Resets an event to its next occurrence
    private func resetEvent(_ event: CountdownEvent, to nextDate: Date) {
        let calendar = Calendar.current

        // Set createdDate to NOW so countdown starts immediately
        let newCreatedDate = Date()

        // Update event dates
        event.targetDate = nextDate
        event.createdDate = newCreatedDate

        // Mark as repeat occurrence for filtering purposes
        event.isRepeatOccurrence = true

        // Calculate new duration
        let newDuration = nextDate.timeIntervalSince(newCreatedDate)

        print("✅ EventRepeatManager: Reset complete")
        print("   - New target: \(nextDate)")
        print("   - New created: \(newCreatedDate) (NOW)")
        print("   - Duration: \(Int(newDuration / 86400)) days")
    }

    /// Updates widget data after event changes
    private func updateWidgetData(context: ModelContext) {
        let descriptor = FetchDescriptor<CountdownEvent>()
        guard let allEvents = try? context.fetch(descriptor) else { return }
        WidgetDataManager.shared.updateWithEvents(allEvents)
    }

    // MARK: - Completion Status

    /// Check if event should show "✓ Completed" badge (within 24 hours of completion)
    func shouldShowCompletedBadge(for event: CountdownEvent) -> Bool {
        guard event.repeats && event.isCompleted else {
            return event.isCompleted
        }

        // For repeating events, show completed badge for 24 hours before auto-reset
        let hoursSinceCompletion = Date().timeIntervalSince(event.targetDate) / 3600
        return hoursSinceCompletion >= 0 && hoursSinceCompletion < 24
    }

    /// Get display text for repeat type
    func repeatDisplayText(for event: CountdownEvent) -> String? {
        guard event.repeats else { return nil }

        switch event.repeatType {
        case "Daily":
            return event.repeatInterval == 1 ? "Repeats Daily" : "Repeats Every \(event.repeatInterval) Days"
        case "Weekly":
            return event.repeatInterval == 1 ? "Repeats Weekly" : "Repeats Every \(event.repeatInterval) Weeks"
        case "Monthly":
            return event.repeatInterval == 1 ? "Repeats Monthly" : "Repeats Every \(event.repeatInterval) Months"
        case "Yearly":
            if event.yearlyRepeatStyle == "relativeWeekday" {
                return event.repeatInterval == 1 ? "Repeats Yearly (Relative)" : "Repeats Every \(event.repeatInterval) Years (Relative)"
            } else {
                return event.repeatInterval == 1 ? "Repeats Yearly" : "Repeats Every \(event.repeatInterval) Years"
            }
        default:
            return nil
        }
    }
}

// MARK: - Background Task Support

extension EventRepeatManager {
    /// Call this when app enters foreground to check for any events that may have completed while app was inactive
    func handleAppDidBecomeActive(context: ModelContext) {
        print("🔄 EventRepeatManager: App became active, checking for completed repeat events...")
        updateRepeatingEvents(context: context)
    }

    /// Call this periodically while app is active (e.g., every hour)
    func performPeriodicCheck(context: ModelContext) {
        updateRepeatingEvents(context: context)
    }
}
