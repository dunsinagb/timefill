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
    @State private var selectedIcon = "birthday.cake.fill"
    @State private var startMode: CountdownStartMode = .now
    @State private var showingCalendarImport = false

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
        "headphones", "hifispeaker.fill", "radio.fill",
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
                                .textCase(.lowercase)

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
                                .colorScheme(.dark)
                                .environment(\.locale, Locale(identifier: "en_US"))
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
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .colorScheme(.dark)
                            .environment(\.locale, Locale(identifier: "en_US"))
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("color")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .textCase(.lowercase)

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
                    .disabled(eventName.isEmpty)
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
        let newEvent = CountdownEvent(
            name: eventName,
            targetDate: targetDate,
            colorHex: selectedColor.hex,
            iconName: selectedIcon
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

        dismiss()
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
