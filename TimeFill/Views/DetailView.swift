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
                        forceReAnimate: forceHeatmapReAnimate
                    )
                    .padding(.vertical)

                    // Countdown display
                    if !isCompleted {
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
                    } else {
                        // Completion message
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(Color(hex: event.colorHex))

                            Text("Event Complete!")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .padding()
                    }

                    Spacer(minLength: 60)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
        .onAppear {
            // Delay to trigger heatmap animation after view loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                triggerHeatmapAnimation = true
            }
        }
        .onReceive(timer) { time in
            currentTime = time
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

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(minWidth: 60)

            Text(label)
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

    init(event: CountdownEvent) {
        self.event = event
        _eventName = State(initialValue: event.name)
        _startDate = State(initialValue: event.createdDate)
        _targetDate = State(initialValue: event.targetDate)
        _selectedColor = State(initialValue: ColorTheme.themes.first(where: { $0.hex == event.colorHex }) ?? ColorTheme.themes[0])
        _selectedIcon = State(initialValue: event.iconName)

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
        // Celebrations & Events
        "birthday.cake.fill", "gift.fill", "party.popper.fill", "balloon.fill",
        "sparkles", "star.fill", "trophy.fill", "crown.fill",

        // Love & Relationships
        "heart.fill", "heart.circle.fill", "suit.heart.fill", "face.smiling.fill",

        // Travel & Transportation
        "airplane", "airplane.departure", "airplane.arrival", "car.fill",
        "bus.fill", "ferry.fill", "bicycle",
        "sailboat.fill", "map.fill", "location.fill", "building.2.fill", "house.fill",

        // Work & Career
        "briefcase.fill", "bag.fill", "case.fill", "graduationcap.fill",
        "book.closed.fill", "bookmark.fill", "pencil",
        "chart.bar.fill", "lightbulb.fill", "brain.fill", "medal.fill",

        // Health & Fitness
        "heart.text.square.fill", "cross.fill", "pills.fill",
        "bed.double.fill", "figure.run", "figure.walk",
        "dumbbell.fill", "football.fill", "basketball.fill",
        "baseball.fill", "soccerball",

        // Food & Dining
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill", "mug.fill",
        "carrot.fill", "leaf.fill", "cart.fill",

        // Music & Entertainment
        "music.note", "music.note.list", "music.mic", "guitar",
        "headphones", "speaker.wave.2.fill", "radio",
        "film.fill", "tv.fill", "gamecontroller.fill",
        "dice.fill", "puzzlepiece.fill",

        // Nature & Weather
        "sun.max.fill", "moon.fill", "moon.stars.fill",
        "cloud.fill", "cloud.rain.fill", "cloud.snow.fill", "snowflake",
        "flame.fill", "drop.fill", "tree.fill",
        "mountain.2.fill", "leaf",

        // Animals
        "dog.fill", "cat.fill", "bird.fill", "fish.fill",
        "hare.fill", "tortoise.fill", "pawprint.fill", "ant.fill",
        "ladybug.fill", "lizard.fill",

        // Technology
        "desktopcomputer", "laptopcomputer", "iphone", "ipad",
        "applewatch", "camera.fill", "video.fill", "phone.fill", "envelope.fill",
        "paperplane.fill", "message.fill",

        // Time & Calendar
        "calendar", "calendar.badge.clock", "clock.fill", "timer",
        "stopwatch.fill", "alarm.fill", "hourglass",

        // Money & Shopping
        "dollarsign.circle.fill", "creditcard.fill", "banknote.fill",
        "giftcard.fill",

        // Home & Living
        "building.fill", "lamp.desk.fill", "bed.double.fill",

        // Creative & Hobbies
        "paintbrush.fill", "paintpalette.fill", "photo.fill",
        "scissors", "paperclip", "pin.fill",
        "books.vertical.fill", "magazine.fill", "newspaper.fill",

        // Symbols & Misc
        "flag.fill", "flag.checkered",
        "bell.fill", "megaphone.fill", "speaker.wave.3.fill",
        "bolt.fill", "bolt.heart.fill", "exclamationmark.triangle.fill",
        "checkmark.circle.fill", "xmark.circle.fill", "questionmark.circle.fill",
        "info.circle.fill", "plus.circle.fill", "minus.circle.fill",

        // Special Occasions
        "ticket.fill",

        // Space & Science
        "atom", "wind",

        // Seasonal
        "umbrella.fill"
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

                                DatePicker(
                                    "Start Date",
                                    selection: $startDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
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
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("color")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
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
    }

    private func saveChanges() {
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

        // Reschedule notifications with updated event details
        let preferences = NotificationPreferences.load()
        if preferences.isEnabled {
            NotificationManager.shared.scheduleNotifications(for: event)
        }

        dismiss()
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
