//
//  DetailView.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.triggerReanimation) private var triggerReanimation
    @Bindable var event: CountdownEvent

    @State private var currentTime = Date()
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    @State private var showingInfo = false
    @State private var showingCompletionAnimation = false
    @State private var triggerHeatmapAnimation = false
    @State private var forceHeatmapReAnimate = false
    @State private var wasEdited = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Calculate live countdown values
    private var daysRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentTime, to: event.targetDate)
        return max(components.day ?? 0, 0)
    }

    private var hoursRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentTime, to: event.targetDate)
        return max(components.hour ?? 0, 0)
    }

    private var minutesRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentTime, to: event.targetDate)
        return max(components.minute ?? 0, 0)
    }

    private var secondsRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentTime, to: event.targetDate)
        return max(components.second ?? 0, 0)
    }

    // Calculate time until countdown starts (for scheduled events)
    private var hoursUntilStart: Int {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime, to: event.createdDate)
        return max(components.hour ?? 0, 0)
    }

    private var minutesUntilStart: Int {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime, to: event.createdDate)
        return max(components.minute ?? 0, 0)
    }

    private var secondsUntilStart: Int {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime, to: event.createdDate)
        return max(components.second ?? 0, 0)
    }

    private var isCompleted: Bool {
        currentTime >= event.targetDate
    }

    private var currentProgress: Double {
        let totalTime = event.targetDate.timeIntervalSince(event.createdDate)
        let elapsedTime = currentTime.timeIntervalSince(event.createdDate)
        return min(max(elapsedTime / totalTime, 0.0), 1.0)
    }

    private var totalDays: Int {
        let components = Calendar.current.dateComponents([.day], from: event.createdDate, to: event.targetDate)
        return max(components.day ?? 1, 1)
    }

    private var daysSinceStart: Int {
        let components = Calendar.current.dateComponents([.day], from: event.createdDate, to: currentTime)
        let days = max(components.day ?? 0, 0)
        // Cap at totalDays when event is completed to ensure all boxes are filled
        return min(days, totalDays)
    }

    private var repeatMessage: String {
        guard event.repeats else { return "" }

        let interval = event.repeatInterval
        let calendar = Calendar.current

        switch event.repeatType {
        case "Daily":
            if interval == 1 {
                return "Countdown will repeat daily"
            } else {
                return "Countdown will repeat every \(interval) days"
            }

        case "Weekly":
            let dayOfWeek = dayOfWeekName(from: event.targetDate)
            if interval == 1 {
                return "Countdown will repeat weekly on \(dayOfWeek)"
            } else {
                return "Countdown will repeat every \(interval) weeks on \(dayOfWeek)"
            }

        case "Monthly":
            let dayOfMonth = calendar.component(.day, from: event.targetDate)
            let ordinalDay = ordinalString(for: dayOfMonth)
            if interval == 1 {
                return "Countdown will repeat monthly on the \(ordinalDay)"
            } else {
                return "Countdown will repeat every \(interval) months on the \(ordinalDay)"
            }

        case "Yearly":
            if event.yearlyRepeatStyle == "relativeWeekday" {
                // Relative weekday style
                let dayOfMonth = calendar.component(.day, from: event.targetDate)
                let weekdayOrdinal = (dayOfMonth - 1) / 7 + 1
                let ordinalWords = ["", "first", "second", "third", "fourth", "fifth"]
                let ordinalWord = weekdayOrdinal <= 5 ? ordinalWords[weekdayOrdinal] : "\(weekdayOrdinal)th"

                let weekdayName = dayOfWeekName(from: event.targetDate)
                let monthName = monthName(from: event.targetDate)

                if interval == 1 {
                    return "Countdown will repeat yearly on the \(ordinalWord) \(weekdayName) of \(monthName)"
                } else {
                    return "Countdown will repeat every \(interval) years on the \(ordinalWord) \(weekdayName) of \(monthName)"
                }
            } else {
                // Fixed date style
                let monthName = monthName(from: event.targetDate)
                let dayOfMonth = calendar.component(.day, from: event.targetDate)
                if interval == 1 {
                    let ordinalDay = ordinalString(for: dayOfMonth)
                    return "Countdown will repeat yearly on \(monthName) \(ordinalDay)"
                } else {
                    return "Countdown will repeat every \(interval) years on \(monthName) \(dayOfMonth)"
                }
            }

        default:
            return "Countdown will repeat"
        }
    }

    // Helper function to get day of week name
    private func dayOfWeekName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name (e.g., "Sunday")
        return formatter.string(from: date)
    }

    // Helper function to get month name
    private func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // Short month name (e.g., "Nov")
        return formatter.string(from: date)
    }

    // Helper function to get ordinal suffix for numbers
    private func ordinalString(for number: Int) -> String {
        let suffix: String
        switch number {
        case 1, 21, 31:
            suffix = "st"
        case 2, 22:
            suffix = "nd"
        case 3, 23:
            suffix = "rd"
        default:
            suffix = "th"
        }
        return "\(number)\(suffix)"
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(hex: event.colorHex).opacity(0.3),
                    Color.timeFillDarkBg,
                    Color.timeFillDarkBg
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Event title
                    Text(event.name)
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    // Scheduled for
                    VStack(spacing: 8) {
                        Text("Scheduled for")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.gray)

                        Text(event.targetDate, format: .dateTime.weekday().month().day().year())
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text(event.targetDate, format: .dateTime.hour().minute())
                            .font(.system(.title3, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    // Large heatmap
                    LargeSandFillView(
                        progress: currentProgress,
                        color: Color(hex: event.colorHex),
                        totalDays: totalDays,
                        elapsedDays: daysSinceStart,
                        shouldAnimate: triggerHeatmapAnimation,
                        forceReAnimate: forceHeatmapReAnimate,
                        targetDate: event.targetDate,
                        actualDaysRemaining: daysRemaining
                    )
                    .padding(.vertical)

                    // Countdown display
                    if event.isScheduled {
                        // Scheduled event - show days/hours until start or time if today
                        if event.startsToday {
                            // Starts within 24 hours - show time countdown
                            VStack(spacing: 12) {
                                VStack(spacing: 12) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 64))
                                        .foregroundStyle(Color(hex: event.colorHex))

                                    // Check if actually today vs tomorrow
                                    let isActuallyToday = Calendar.current.isDateInToday(event.createdDate)
                                    Text(isActuallyToday ? "Starts Today" : "Starts Tomorrow")
                                        .font(.system(.title2, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)

                                    // Time countdown box
                                    HStack(spacing: 0) {
                                        CountdownUnit(value: hoursUntilStart, label: "Hours")
                                        CountdownUnit(value: minutesUntilStart, label: "Minutes")
                                        CountdownUnit(value: secondsUntilStart, label: "Seconds")
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: event.colorHex).opacity(0.2))
                                )

                                // Repeat message (outside box)
                                if event.repeats {
                                    Text(repeatMessage)
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                }
                            }
                        } else {
                            // Multiple days until start
                            VStack(spacing: 12) {
                                VStack(spacing: 12) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 64))
                                        .foregroundStyle(Color(hex: event.colorHex))

                                    Text("Starts in \(event.daysUntilStart) \(event.daysUntilStart == 1 ? "day" : "days")")
                                        .font(.system(.title2, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)

                                    Text("Countdown begins on")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.gray)

                                    Text(event.createdDate, format: .dateTime.weekday().month().day().year())
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: event.colorHex).opacity(0.2))
                                )

                                // Repeat message (outside box)
                                if event.repeats {
                                    Text(repeatMessage)
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                }
                            }
                        }
                    } else if !isCompleted {
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                CountdownUnit(value: daysRemaining, label: "Days")
                                CountdownUnit(value: hoursRemaining, label: "Hours")
                                CountdownUnit(value: minutesRemaining, label: "Minutes")
                                CountdownUnit(value: secondsRemaining, label: "Seconds")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: event.colorHex).opacity(0.2))
                            )

                            // Repeat message (outside box)
                            if event.repeats {
                                Text(repeatMessage)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                        }
                    } else {
                        // Completion message
                        VStack(spacing: 12) {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(Color(hex: event.colorHex))

                                Text("Countdown Complete!")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                            .padding()

                            // Repeat message (outside box)
                            if event.repeats {
                                Text(repeatMessage)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                        }
                    }

                    Spacer(minLength: 60)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    // Info button
                    Button(action: { showingInfo = true }) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.white)
                    }

                    // Menu button
                    Menu {
                        Button(action: { showingEdit = true }) {
                            Label("Edit", systemImage: "slider.horizontal.3")
                        }

                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .onAppear {
            // Delay to trigger heatmap animation after view loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                triggerHeatmapAnimation = true
            }
        }
        .onReceive(timer) { time in
            currentTime = time
        }
        .sheet(isPresented: $showingInfo) {
            EventInfoSheet(event: event)
        }
        .sheet(isPresented: $showingEdit) {
            EditEventView(event: event)
        }
        .onChange(of: showingEdit) { _, isShowing in
            // Re-trigger animation when returning from edit
            if !isShowing {
                // Mark that this event was edited
                wasEdited = true

                // Re-trigger heatmap animation on detail page using toggle approach
                // Delay to ensure view is ready after sheet dismissal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    forceHeatmapReAnimate.toggle()
                }
            }
        }
        .onDisappear {
            // When navigating back to overview after editing, trigger re-animation
            if wasEdited {
                triggerReanimation?(event.id)
            }
        }
        .alert("Delete Event", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("Are you sure you want to delete \"\(event.name)\"?")
        }
    }

    private func deleteEvent() {
        modelContext.delete(event)
        dismiss()
    }
}

struct CountdownUnit: View {
    let value: Int
    let label: String

    private var displayLabel: String {
        if value == 1 {
            // Remove 's' from end for singular
            return label.hasSuffix("s") ? String(label.dropLast()) : label
        }
        return label
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(minWidth: 60)

            Text(displayLabel)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// Edit Event View
struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var event: CountdownEvent

    @State private var eventName: String
    @State private var startDate: Date
    @State private var targetDate: Date
    @State private var selectedColor: ColorTheme
    @State private var selectedIcon: String
    @State private var startMode: CountdownStartMode
    @State private var repeatType: String
    @State private var repeatInterval: Int
    @State private var yearlyRepeatStyle: String
    @State private var showingRepeatOptions = false
    @State private var attemptedSave = false

    // Custom color picker
    @State private var showingCustomColorPicker = false
    @State private var customPickedColor: Color = .blue
    @State private var customColorTheme: ColorTheme? = nil

    init(event: CountdownEvent) {
        self.event = event
        _eventName = State(initialValue: event.name)
        _startDate = State(initialValue: event.createdDate)
        _targetDate = State(initialValue: event.targetDate)

        // Check if event uses a custom color (not in preset themes)
        if let presetTheme = ColorTheme.themes.first(where: { $0.hex == event.colorHex }) {
            _selectedColor = State(initialValue: presetTheme)
        } else {
            // Custom color - create a custom theme and set it
            let customTheme = ColorTheme(hex: event.colorHex, name: "Custom")
            _selectedColor = State(initialValue: customTheme)
            _customColorTheme = State(initialValue: customTheme)
            _customPickedColor = State(initialValue: Color(hex: event.colorHex))
        }

        _selectedIcon = State(initialValue: event.iconName)
        _repeatType = State(initialValue: event.repeatType)
        _repeatInterval = State(initialValue: event.repeatInterval)
        _yearlyRepeatStyle = State(initialValue: event.yearlyRepeatStyle)

        // Determine initial mode based on current start date
        let now = Date()
        if abs(event.createdDate.timeIntervalSince(now)) < 60 {
            _startMode = State(initialValue: .now)
        } else if event.createdDate < now {
            _startMode = State(initialValue: .past)
        } else {
            _startMode = State(initialValue: .future)
        }
    }

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

                            StartModeSegmentedControl(mode: $startMode, startDate: $startDate)
                        }

                        // Start Date Picker (only for Past or Future)
                        if startMode != .now {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(startMode == .past ? "start date (past)" : "start date (future)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.gray)

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

                        // Icon picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("icon")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)

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
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundStyle(Color.timeFillCyan)
                }
            }
        }
        .preferredColorScheme(.dark)
        .background(
            ColorPickerWrapper(
                selectedColor: $customPickedColor,
                isPresented: $showingCustomColorPicker,
                onColorSelected: { color in
                    // Create custom theme from picked color
                    let hexString = color.toHex()
                    let newCustomTheme = ColorTheme(hex: hexString, name: "Custom")
                    customColorTheme = newCustomTheme
                    selectedColor = newCustomTheme
                }
            )
            .frame(width: 0, height: 0)
        )
    }

    private func saveChanges() {
        // Validate event name
        attemptedSave = true
        guard !eventName.isEmpty else { return }

        event.name = eventName
        // Set start date based on mode
        if startMode == .now {
            event.createdDate = Date()
        } else {
            event.createdDate = startDate
        }
        event.targetDate = targetDate
        event.colorHex = selectedColor.hex
        event.iconName = selectedIcon
        event.repeatType = repeatType
        event.repeatInterval = repeatInterval
        event.yearlyRepeatStyle = yearlyRepeatStyle

        // Reschedule notifications with updated event details
        let preferences = NotificationPreferences.load()
        if preferences.isEnabled {
            NotificationManager.shared.scheduleNotifications(for: event)
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CountdownEvent.self, configurations: config)

    let sampleEvent = CountdownEvent(
        name: "Wifey bday",
        targetDate: Calendar.current.date(byAdding: .day, value: 149, to: Date())!,
        colorHex: "#36C2FF",
        iconName: "birthday.cake.fill"
    )

    container.mainContext.insert(sampleEvent)

    return NavigationStack {
        DetailView(event: sampleEvent)
    }
    .modelContainer(container)
}

// MARK: - Event Info Sheet
struct EventInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var event: CountdownEvent

    var body: some View {
        NavigationStack {
            ZStack {
                Color.timeFillDarkBg
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Event icon and name
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: event.colorHex).opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: event.iconName)
                                .font(.system(size: 40))
                                .foregroundStyle(Color(hex: event.colorHex))
                        }

                        Text(event.name)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Info cards
                    VStack(spacing: 16) {
                        // Event was created on
                        InfoCard(
                            title: "Created On",
                            date: event.addedToAppDate,
                            icon: "calendar.badge.plus",
                            color: Color.timeFillCyan
                        )

                        // Countdown starts on
                        InfoCard(
                            title: "Start Date & Time",
                            date: event.createdDate,
                            icon: "clock.arrow.circlepath",
                            color: Color(hex: event.colorHex)
                        )

                        // Event scheduled for
                        InfoCard(
                            title: "Scheduled For",
                            date: event.targetDate,
                            icon: "calendar.badge.clock",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("Event Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.timeFillDarkBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.timeFillCyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let title: String
    let date: Date
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 30)

                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(date, format: .dateTime.weekday().month().day().year())
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(date, format: .dateTime.hour().minute())
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
