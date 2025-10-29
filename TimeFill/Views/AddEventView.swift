//
//  AddEventView.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI
import SwiftData

enum CountdownStartMode: String, CaseIterable {
    case past = "Past"
    case now = "Now"
    case future = "Future"
}

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var eventName = ""
    @State private var startDate = Date()
    @State private var targetDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var selectedColor = ColorTheme.themes[0]
    @State private var selectedIcon = "heart.fill"
    @State private var startMode: CountdownStartMode = .now
    @State private var showingCalendarImport = false
    @State private var repeatType = "Never"
    @State private var repeatInterval = 1
    @State private var yearlyRepeatStyle = "fixedDate"
    @State private var showingRepeatOptions = false
    @State private var attemptedSave = false

    // Custom color picker
    @State private var showingCustomColorPicker = false
    @State private var customPickedColor: Color = .blue
    @State private var customColorTheme: ColorTheme? = nil

    private let icons = [
        // Most Popular - Top Row
        "heart.fill", "star.fill", "calendar", "gift.fill",
        "birthday.cake.fill", "airplane", "car.fill", "house.fill",
        "bell.fill", "flag.fill", "trophy.fill", "crown.fill",

        // Celebrations & Special Occasions
        "party.popper.fill", "balloon.fill", "sparkles", "ticket.fill",

        // Love & Relationships
        "heart.circle.fill", "suit.heart.fill", "face.smiling.fill",

        // Travel & Transportation
        "airplane.departure", "airplane.arrival", "map.fill", "location.fill",
        "bus.fill", "ferry.fill", "bicycle", "sailboat.fill", "building.2.fill",

        // Work & Career
        "briefcase.fill", "bag.fill", "graduationcap.fill",
        "book.closed.fill", "bookmark.fill", "pencil",
        "chart.bar.fill", "lightbulb.fill", "brain.fill", "medal.fill",

        // Time & Productivity
        "calendar.badge.clock", "clock.fill", "timer",
        "stopwatch.fill", "alarm.fill", "hourglass",

        // Communication & Social
        "phone.fill", "envelope.fill", "message.fill", "paperplane.fill",

        // Health & Fitness
        "heart.text.square.fill", "cross.fill", "pills.fill",
        "bed.double.fill", "figure.run", "figure.walk",
        "dumbbell.fill", "football.fill", "basketball.fill",
        "baseball.fill", "soccerball",

        // Food & Dining
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill", "mug.fill",
        "carrot.fill", "cart.fill",

        // Music & Entertainment
        "music.note", "music.note.list", "music.mic", "guitar",
        "headphones", "radio",
        "film.fill", "tv.fill", "gamecontroller.fill",
        "dice.fill", "puzzlepiece.fill",

        // Nature & Weather
        "sun.max.fill", "moon.fill", "moon.stars.fill",
        "cloud.fill", "cloud.rain.fill", "cloud.snow.fill", "snowflake",
        "flame.fill", "drop.fill", "tree.fill", "leaf",
        "mountain.2.fill", "umbrella.fill",

        // Animals & Pets
        "dog.fill", "cat.fill", "bird.fill", "fish.fill",
        "hare.fill", "tortoise.fill", "pawprint.fill", "ant.fill",
        "ladybug.fill", "lizard.fill",

        // Technology & Devices
        "iphone", "ipad", "applewatch",
        "desktopcomputer", "laptopcomputer",
        "camera.fill", "video.fill",

        // Money & Shopping
        "dollarsign.circle.fill", "creditcard.fill", "banknote.fill",
        "giftcard.fill",

        // Home & Living
        "building.fill", "lamp.desk.fill", "bed.double.fill",

        // Creative & Hobbies
        "paintbrush.fill", "paintpalette.fill", "photo.fill",
        "scissors", "paperclip", "pin.fill",
        "books.vertical.fill", "magazine.fill", "newspaper.fill",

        // Symbols & Actions
        "flag.checkered", "megaphone.fill", "speaker.wave.3.fill",
        "bolt.fill", "bolt.heart.fill", "exclamationmark.triangle.fill",
        "checkmark.circle.fill", "xmark.circle.fill", "questionmark.circle.fill",
        "info.circle.fill", "plus.circle.fill", "minus.circle.fill",
        "case.fill", "atom", "wind"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.timeFillDarkBg
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Event name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("name")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .textCase(.lowercase)

                            TextField("Event name", text: $eventName)
                                .font(.system(.body, design: .rounded))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundStyle(.white)

                            // Validation message - only show after save attempt
                            if attemptedSave && eventName.isEmpty {
                                Text("Please enter an event name")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                        }

                        // Countdown Start Mode Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("countdown start")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .textCase(.lowercase)

                            StartModeSegmentedControl(mode: $startMode, startDate: $startDate)
                        }

                        // Start Date Picker (only for Past or Future)
                        if startMode != .now {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(startMode == .past ? "start date (past)" : "start date (future)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.gray)
                                    .textCase(.lowercase)

                                if startMode == .past {
                                    DatePicker(
                                        "Start Date",
                                        selection: $startDate,
                                        in: ...Date(),
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .colorScheme(.dark)
                                    .environment(\.locale, Locale(identifier: "en_US"))
                                    .onChange(of: startDate) { _, newStartDate in
                                        // If target date is before or equal to new start date, adjust it
                                        if targetDate <= newStartDate {
                                            targetDate = Calendar.current.date(byAdding: .day, value: 30, to: newStartDate) ?? newStartDate
                                        }
                                    }
                                } else {
                                    DatePicker(
                                        "Start Date",
                                        selection: $startDate,
                                        in: Date()...,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .colorScheme(.dark)
                                    .environment(\.locale, Locale(identifier: "en_US"))
                                    .onChange(of: startDate) { _, newStartDate in
                                        // If target date is before or equal to new start date, adjust it
                                        if targetDate <= newStartDate {
                                            targetDate = Calendar.current.date(byAdding: .day, value: 30, to: newStartDate) ?? newStartDate
                                        }
                                    }
                                }
                            }
                        }

                        // Event date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("event date")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .textCase(.lowercase)

                            DatePicker(
                                "Target Date",
                                selection: $targetDate,
                                in: startDate...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .colorScheme(.dark)
                            .environment(\.locale, Locale(identifier: "en_US"))

                            // Validation message
                            if targetDate <= startDate {
                                Text("Event date must be after countdown start")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                        }

                        // Repeat selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("repeat")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .textCase(.lowercase)

                            Button(action: { showingRepeatOptions.toggle() }) {
                                HStack {
                                    Image(systemName: "repeat")
                                        .foregroundStyle(Color.timeFillCyan)
                                        .frame(width: 24)

                                    Text(repeatType == "Never" ? "Never" : "Every \(repeatInterval) \(repeatTypeLabel())")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Image(systemName: showingRepeatOptions ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }

                            // Repeat options panel
                            if showingRepeatOptions {
                                VStack(spacing: 12) {
                                    // Repeat type buttons
                                    VStack(spacing: 8) {
                                        ForEach(["Never", "Daily", "Weekly", "Monthly", "Yearly"], id: \.self) { type in
                                            Button(action: {
                                                repeatType = type
                                                if type == "Never" {
                                                    repeatInterval = 1
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: repeatType == type ? "checkmark.circle.fill" : "circle")
                                                        .foregroundStyle(repeatType == type ? Color.timeFillCyan : .gray)

                                                    Text(type)
                                                        .font(.system(.body, design: .rounded))
                                                        .foregroundStyle(.white)

                                                    Spacer()
                                                }
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(repeatType == type ? Color.timeFillCyan.opacity(0.2) : Color.white.opacity(0.05))
                                                )
                                            }
                                        }
                                    }

                                    // Interval picker (only show if not "Never")
                                    if repeatType != "Never" {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("repeat every")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundStyle(.gray)
                                                .textCase(.lowercase)

                                            HStack {
                                                Button(action: {
                                                    if repeatInterval > 1 {
                                                        repeatInterval -= 1
                                                    }
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(repeatInterval > 1 ? Color.timeFillCyan : .gray)
                                                }
                                                .disabled(repeatInterval <= 1)

                                                Text("\(repeatInterval)")
                                                    .font(.system(.title2, design: .rounded))
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                    .frame(minWidth: 40)

                                                Button(action: {
                                                    if repeatInterval < 99 {
                                                        repeatInterval += 1
                                                    }
                                                }) {
                                                    Image(systemName: "plus.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(repeatInterval < 99 ? Color.timeFillCyan : .gray)
                                                }
                                                .disabled(repeatInterval >= 99)

                                                Text(repeatTypeLabel())
                                                    .font(.system(.body, design: .rounded))
                                                    .foregroundStyle(.gray)
                                                    .padding(.leading, 8)
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(12)
                                        }

                                        // Yearly repeat style option (only show for Yearly)
                                        if repeatType == "Yearly" {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("repeat style")
                                                    .font(.system(.caption, design: .rounded))
                                                    .foregroundStyle(.gray)
                                                    .textCase(.lowercase)

                                                VStack(spacing: 8) {
                                                    Button(action: {
                                                        yearlyRepeatStyle = "fixedDate"
                                                    }) {
                                                        HStack {
                                                            Image(systemName: yearlyRepeatStyle == "fixedDate" ? "checkmark.circle.fill" : "circle")
                                                                .foregroundStyle(yearlyRepeatStyle == "fixedDate" ? Color.timeFillCyan : .gray)

                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text("Fixed Date")
                                                                    .font(.system(.body, design: .rounded))
                                                                    .foregroundStyle(.white)
                                                                Text(yearlyFixedDateExample())
                                                                    .font(.system(.caption, design: .rounded))
                                                                    .foregroundStyle(.gray)
                                                            }

                                                            Spacer()
                                                        }
                                                        .padding(.vertical, 10)
                                                        .padding(.horizontal, 12)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .fill(yearlyRepeatStyle == "fixedDate" ? Color.timeFillCyan.opacity(0.2) : Color.white.opacity(0.05))
                                                        )
                                                    }

                                                    Button(action: {
                                                        yearlyRepeatStyle = "relativeWeekday"
                                                    }) {
                                                        HStack {
                                                            Image(systemName: yearlyRepeatStyle == "relativeWeekday" ? "checkmark.circle.fill" : "circle")
                                                                .foregroundStyle(yearlyRepeatStyle == "relativeWeekday" ? Color.timeFillCyan : .gray)

                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text("Relative Weekday")
                                                                    .font(.system(.body, design: .rounded))
                                                                    .foregroundStyle(.white)
                                                                Text(yearlyRelativeWeekdayExample())
                                                                    .font(.system(.caption, design: .rounded))
                                                                    .foregroundStyle(.gray)
                                                            }

                                                            Spacer()
                                                        }
                                                        .padding(.vertical, 10)
                                                        .padding(.horizontal, 12)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .fill(yearlyRepeatStyle == "relativeWeekday" ? Color.timeFillCyan.opacity(0.2) : Color.white.opacity(0.05))
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.03))
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("color")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .textCase(.lowercase)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                                // Preset colors
                                ForEach(ColorTheme.themes) { theme in
                                    Circle()
                                        .fill(theme.color)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor.id == theme.id ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = theme
                                        }
                                }

                                // Custom color picker button (last option)
                                // ALWAYS shows palette icon, even after selecting a color
                                ZStack {
                                    Circle()
                                        .fill(customColorTheme?.color ?? Color.white.opacity(0.2))
                                        .frame(width: 60, height: 60)

                                    // Always show palette icon to indicate this is the custom picker
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.white.opacity(customColorTheme == nil ? 0.5 : 0.9))
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: customColorTheme != nil && selectedColor.id == customColorTheme!.id ? 3 : 0)
                                )
                                .onTapGesture {
                                    showingCustomColorPicker = true
                                }
                            }
                        }
                        .sheet(isPresented: $showingCustomColorPicker) {
                            ColorPickerViewController(
                                selectedColor: $customPickedColor,
                                onColorSelected: { color in
                                    // Create custom theme from picked color
                                    let hexString = color.toHex()
                                    let newCustomTheme = ColorTheme(hex: hexString, name: "Custom")
                                    customColorTheme = newCustomTheme
                                    selectedColor = newCustomTheme
                                }
                            )
                            .presentationDetents([.height(580)])
                            .presentationDragIndicator(.visible)
                        }

                        // Icon picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("icon")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .textCase(.lowercase)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                                ForEach(icons, id: \.self) { icon in
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: icon)
                                                .font(.title2)
                                                .foregroundStyle(selectedIcon == icon ? selectedColor.color : .gray)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor.color, lineWidth: selectedIcon == icon ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            selectedIcon = icon
                                        }
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // Floating calendar import button
                Button(action: { showingCalendarImport = true }) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.timeFillCyan)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.timeFillDarkBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .foregroundStyle(Color.timeFillCyan)
                    .disabled(targetDate <= startDate)
                }
            }
            .sheet(isPresented: $showingCalendarImport) {
                CalendarImportView(onDismissToRoot: {
                    // Dismiss the AddEventView when import is complete
                    dismiss()
                })
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveEvent() {
        // Validate event name
        attemptedSave = true
        guard !eventName.isEmpty else { return }

        let newEvent = CountdownEvent(
            name: eventName,
            targetDate: targetDate,
            colorHex: selectedColor.hex,
            iconName: selectedIcon,
            repeatType: repeatType,
            repeatInterval: repeatInterval,
            yearlyRepeatStyle: yearlyRepeatStyle
        )
        // Set start date based on mode
        if startMode == .now {
            newEvent.createdDate = Date()
        } else {
            newEvent.createdDate = startDate
        }
        modelContext.insert(newEvent)

        // Schedule notifications for the new event
        let preferences = NotificationPreferences.load()
        if preferences.isEnabled {
            NotificationManager.shared.scheduleNotifications(for: newEvent)
        }

        // If event repeats, create next occurrence
        if repeatType != "Never" {
            createNextOccurrence(from: newEvent)
        }

        dismiss()
    }

    private func repeatTypeLabel() -> String {
        switch repeatType {
        case "Daily":
            return repeatInterval == 1 ? "day" : "days"
        case "Weekly":
            return repeatInterval == 1 ? "week" : "weeks"
        case "Monthly":
            return repeatInterval == 1 ? "month" : "months"
        case "Yearly":
            return repeatInterval == 1 ? "year" : "years"
        default:
            return ""
        }
    }

    private func yearlyFixedDateExample() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "e.g., \(formatter.string(from: targetDate))"
    }

    private func yearlyRelativeWeekdayExample() -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: targetDate)
        let weekdayOrdinal = (dayOfMonth - 1) / 7 + 1

        let ordinalWords = ["", "First", "Second", "Third", "Fourth", "Fifth"]
        let ordinalWord = weekdayOrdinal <= 5 ? ordinalWords[weekdayOrdinal] : "\(weekdayOrdinal)th"

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full weekday name
        let weekdayName = formatter.string(from: targetDate)

        formatter.dateFormat = "MMM" // Short month name
        let monthName = formatter.string(from: targetDate)

        return "e.g., \(ordinalWord) \(weekdayName) of \(monthName)"
    }

    private func createNextOccurrence(from event: CountdownEvent) {
        guard let nextDate = event.nextOccurrenceDate(after: event.targetDate) else { return }

        let nextEvent = CountdownEvent(
            name: event.name,
            targetDate: nextDate,
            colorHex: event.colorHex,
            iconName: event.iconName,
            repeatType: event.repeatType,
            repeatInterval: event.repeatInterval,
            yearlyRepeatStyle: event.yearlyRepeatStyle,
            isRepeatOccurrence: true  // Mark as auto-created repeat occurrence
        )

        // Calculate the time difference between original start and target
        let timeDifference = event.targetDate.timeIntervalSince(event.createdDate)

        // Set the created date for next event based on the new target date
        nextEvent.createdDate = Date(timeInterval: -timeDifference, since: nextDate)

        modelContext.insert(nextEvent)

        // Schedule notifications for the next occurrence
        let preferences = NotificationPreferences.load()
        if preferences.isEnabled {
            NotificationManager.shared.scheduleNotifications(for: nextEvent)
        }
    }
}

// Helper view for countdown start mode picker
struct CountdownStartPicker: View {
    @Binding var mode: CountdownStartMode
    @Binding var startDate: Date
    let targetDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("countdown start")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.gray)
                .textCase(.lowercase)

            // Segmented control
            StartModeSegmentedControl(mode: $mode, startDate: $startDate)

            // Show date picker only for Past or Future
            if mode != .now {
                if mode == .past {
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        in: ...targetDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .colorScheme(.dark)
                } else {
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .colorScheme(.dark)

                    if startDate <= targetDate {
                        Text("Note: future start date must be before event date")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

struct StartModeSegmentedControl: View {
    @Binding var mode: CountdownStartMode
    @Binding var startDate: Date

    var body: some View {
        HStack(spacing: 0) {
            modeButton(.past)
            modeButton(.now)
            modeButton(.future)
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }

    private func modeButton(_ buttonMode: CountdownStartMode) -> some View {
        Button(action: {
            mode = buttonMode
            if buttonMode == .now {
                startDate = Date()
            } else if buttonMode == .future {
                startDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            }
        }) {
            Text(buttonMode.rawValue)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(mode == buttonMode ? Color.timeFillDarkBg : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(mode == buttonMode ? Color.timeFillCyan : Color.clear)
                .cornerRadius(8, corners: corners(for: buttonMode))
        }
    }

    private func corners(for buttonMode: CountdownStartMode) -> UIRectCorner {
        switch buttonMode {
        case .past: return [.topLeft, .bottomLeft]
        case .now: return []
        case .future: return [.topRight, .bottomRight]
        }
    }
}

#Preview {
    AddEventView()
        .modelContainer(for: CountdownEvent.self, inMemory: true)
}
