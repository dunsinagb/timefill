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

    init(name: String, targetDate: Date, colorHex: String = "#36C2FF", iconName: String = "calendar") {
        self.id = UUID()
        self.name = name
        self.targetDate = targetDate
        self.createdDate = Date()
        self.addedToAppDate = Date()  // Always set to now when created
        self.colorHex = colorHex
        self.iconName = iconName
    }

    // Calculate days remaining
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

    // Days until countdown starts (for scheduled events)
    var daysUntilStart: Int {
        guard isScheduled else { return 0 }
        let components = Calendar.current.dateComponents([.day], from: Date(), to: createdDate)
        return max(components.day ?? 0, 0)
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
}
