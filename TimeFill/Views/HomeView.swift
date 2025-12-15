//
//  HomeView.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI
import SwiftData

enum SortOption: String, CaseIterable {
    case date = "Date"
    case name = "Name"
    case progress = "Progress"

    var icon: String {
        switch self {
        case .date: return "calendar"
        case .name: return "textformat.abc"
        case .progress: return "percent"
        }
    }
}

enum FilterOption: String, CaseIterable {
    case all = "All"
    case upcoming = "Upcoming"
    case recurring = "Recurring"
    case past = "Past"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .upcoming: return "clock.arrow.circlepath"
        case .recurring: return "repeat.circle"
        case .past: return "checkmark.circle"
        }
    }
}

struct HomeView: View {
    @Binding var showAddEventFromLanding: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isShowingDetailView) private var isShowingDetailView
    @Query private var allEvents: [CountdownEvent]
    @State private var showingAddEvent = false
    @State private var showingCalendarImport = false
    @AppStorage("showYearOverview") private var showYearOverview = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @State private var yearViewMode: YearViewMode = .year
    @State private var sortOption: SortOption = .date
    @State private var filterOption: FilterOption = .all
    @State private var showingSortMenu = false
    @State private var triggerAnimation = false
    @State private var triggerYearMonthAnimation = false
    @State private var reanimateEventID: UUID?

    private var events: [CountdownEvent] {
        // Apply time-based filter (All, Upcoming, Recurring, Past)
        let filteredEvents: [CountdownEvent]
        switch filterOption {
        case .all:
            filteredEvents = allEvents
        case .upcoming:
            // Show scheduled + active events (not completed)
            filteredEvents = allEvents.filter { !$0.isCompleted }
        case .recurring:
            // Show only events that have repeat enabled
            filteredEvents = allEvents.filter { $0.repeats }
        case .past:
            // Show only completed events
            filteredEvents = allEvents.filter { $0.isCompleted }
        }

        // Apply sorting
        switch sortOption {
        case .date:
            return filteredEvents.sorted { $0.targetDate < $1.targetDate }
        case .name:
            return filteredEvents.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .progress:
            return filteredEvents.sorted {
                let progress0 = calculateProgress(for: $0)
                let progress1 = calculateProgress(for: $1)
                return progress0 > progress1 // Highest progress first
            }
        }
    }

    private func calculateProgress(for event: CountdownEvent) -> Double {
        let totalTime = event.targetDate.timeIntervalSince(event.createdDate)
        let elapsedTime = Date().timeIntervalSince(event.createdDate)
        return min(max(elapsedTime / totalTime, 0.0), 1.0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.timeFillDarkBg
                    .ignoresSafeArea()

                if allEvents.isEmpty {
                    // Empty state - no events in database at all
                    VStack(spacing: 16) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 64))
                            .foregroundStyle(.gray)

                        Text("No events yet")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text("Add one and let time start flowing")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)

                        Button(action: {
                            if hapticsEnabled {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                            showingAddEvent = true
                        }) {
                            Label("Add Event", systemImage: "plus.circle.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.timeFillCyan)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                } else {
                    // Events list
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Year/Month Overview Card
                            if showYearOverview {
                                YearOverviewCard(mode: $yearViewMode, shouldAnimate: $triggerYearMonthAnimation)
                            }

                            // Filter options
                            HStack(spacing: 6) {
                                ForEach(FilterOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            filterOption = option
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: option.icon)
                                                .font(.system(size: 11))
                                            Text(option.rawValue)
                                                .font(.system(size: 11, design: .rounded))
                                                .fontWeight(.medium)
                                        }
                                        .foregroundStyle(filterOption == option ? .white : .gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(filterOption == option ? Color.timeFillCyan : Color.white.opacity(0.1))
                                        )
                                    }
                                    .sensoryFeedback(.selection, trigger: filterOption == option) { _, newValue in
                                        hapticsEnabled && newValue
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)

                            // Empty state for filtered results
                            if events.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: filterOption.icon)
                                        .font(.system(size: 48))
                                        .foregroundStyle(.gray.opacity(0.6))
                                        .padding(.top, 40)

                                    Text("No \(filterOption.rawValue.lowercased()) events")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            }

                            ForEach(events) { event in
                                NavigationLink(destination: DetailView(event: event)
                                    .environment(\.triggerReanimation, { eventID in
                                        reanimateEventID = eventID
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                                            reanimateEventID = nil
                                        }
                                    })
                                    .onAppear {
                                        isShowingDetailView?.wrappedValue = true
                                    }
                                    .onDisappear {
                                        isShowingDetailView?.wrappedValue = false
                                    }
                                ) {
                                    EventCardView(
                                        event: event,
                                        shouldAnimate: $triggerAnimation,
                                        forceAnimate: event.id == reanimateEventID
                                    )
                                }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding()
                        .onAppear {
                            if !triggerAnimation {
                                // Delay to ensure views are loaded before triggering animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    triggerAnimation = true
                                }
                            }
                            // Update widget data
                            updateWidgetData()
                        }
                        .onChange(of: allEvents.count) { _, _ in
                            // Update widget when events change
                            updateWidgetData()
                        }
                    }
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
            .navigationTitle("Overview")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Event count
                    Text("\(events.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    // Sort button
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                if hapticsEnabled {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                                sortOption = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Toggle year overview visibility
                    Button(action: {
                        if hapticsEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                        showYearOverview.toggle()
                    }) {
                        Image(systemName: showYearOverview ? "eye.fill" : "eye.slash.fill")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }

                    Button(action: {
                        if hapticsEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                        showingAddEvent = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.timeFillCyan)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
            .sheet(isPresented: $showingCalendarImport) {
                CalendarImportView()
            }
            .onChange(of: showAddEventFromLanding) { _, newValue in
                if newValue {
                    showingAddEvent = true
                    showAddEventFromLanding = false
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Widget Data Update
    private func updateWidgetData() {
        WidgetDataManager.shared.updateWithEvents(allEvents)
    }
}

struct EventCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var event: CountdownEvent
    @Binding var shouldAnimate: Bool
    var forceAnimate: Bool = false
    @State private var currentTime = Date()
    @State private var animationTrigger = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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

    // Calculate hours remaining for scheduled events starting today
    private var hoursUntilStart: Int {
        let components = Calendar.current.dateComponents([.hour], from: currentTime, to: event.createdDate)
        return max(components.hour ?? 0, 0)
    }

    // Calculate actual days remaining (using full days, not calendar days)
    private var actualDaysRemaining: Int {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentTime, to: event.targetDate)
        return max(components.day ?? 0, 0)
    }

    // Calculate total hours remaining (for events within 24 hours)
    private var totalHoursRemaining: Int {
        let interval = event.targetDate.timeIntervalSince(currentTime)
        return max(Int(interval / 3600), 0)
    }

    // Check if event ends within 24 hours
    private var endsWithin24Hours: Bool {
        return totalHoursRemaining < 24
    }

    // Calculate total hours until start (for scheduled events within 24 hours)
    private var totalHoursUntilStart: Int {
        let interval = event.createdDate.timeIntervalSince(currentTime)
        return max(Int(interval / 3600), 0)
    }

    // Check if event starts within 24 hours
    private var startsWithin24Hours: Bool {
        return totalHoursUntilStart < 24
    }

    // Get display text for scheduled events
    private var scheduledDisplayText: String {
        if startsWithin24Hours {
            return "Starts in \(totalHoursUntilStart)H"
        } else if event.daysUntilStart == 1 {
            return "Starts in 1D"
        } else {
            return "Starts in \(event.daysUntilStart)D"
        }
    }

    // Get display text for active events
    private var activeDisplayText: String {
        if endsWithin24Hours {
            return "\(totalHoursRemaining)H Left · \(Int(currentProgress * 100))%"
        } else if actualDaysRemaining == 1 {
            return "1D Left · \(Int(currentProgress * 100))%"
        } else {
            return "\(actualDaysRemaining)D Left · \(Int(currentProgress * 100))%"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: event.colorHex).opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: event.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: event.colorHex))

                // Top badge: Scheduled or Completed
                if event.isScheduled {
                    // Scheduled badge for future events (top right)
                    Circle()
                        .fill(Color.timeFillDarkBg)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: event.colorHex))
                        )
                        .offset(x: 18, y: -18)
                } else if currentProgress >= 1.0 {
                    // Checkmark badge for completed events (top right)
                    Circle()
                        .fill(Color.timeFillDarkBg)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: event.colorHex))
                        )
                        .offset(x: 18, y: -18)
                }

                // Bottom badge: Repeat (can show with any top badge)
                if event.repeats {
                    Circle()
                        .fill(Color.timeFillDarkBg)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "repeat.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: event.colorHex))
                        )
                        .offset(x: 18, y: 18)
                }
            }

            // Event details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .truncationMode(.tail)

                // Show time remaining for scheduled or active events
                if event.isScheduled {
                    Text(scheduledDisplayText)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.gray)
                } else {
                    Text(activeDisplayText)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.gray)
                }
            }

            Spacer()

            // Heatmap visualization
            CompactSandFillView(
                progress: currentProgress,
                color: Color(hex: event.colorHex),
                totalDays: totalDays,
                elapsedDays: daysSinceStart,
                shouldAnimate: shouldAnimate,
                forceReAnimate: animationTrigger
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onReceive(timer) { time in
            currentTime = time

            // Check if repeat event should reset
            if event.shouldResetRepeat {
                Task { @MainActor in
                    EventRepeatManager.shared.handleRepeatLogic(for: event, context: modelContext)
                }
            }
        }
        .onChange(of: forceAnimate) { _, newValue in
            if newValue {
                // Toggle animation trigger to force re-animation
                animationTrigger.toggle()
            }
        }
    }
}

enum YearViewMode: String {
    case year = "Year"
    case month = "Month"
}

struct YearOverviewCard: View {
    @Binding var mode: YearViewMode
    @Binding var shouldAnimate: Bool
    @State private var currentTime = Date()
    @State private var animationTrigger = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var totalDays: Int {
        switch mode {
        case .year:
            // Days in current year
            let calendar = Calendar.current
            let year = calendar.component(.year, from: currentTime)
            let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
            let components = calendar.dateComponents([.day], from: startOfYear, to: endOfYear)
            return (components.day ?? 365) + 1
        case .month:
            // Days in current month
            let calendar = Calendar.current
            let range = calendar.range(of: .day, in: .month, for: currentTime)!
            return range.count
        }
    }

    private var elapsedDays: Int {
        let calendar = Calendar.current
        switch mode {
        case .year:
            // Days elapsed in current year
            let year = calendar.component(.year, from: currentTime)
            let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let components = calendar.dateComponents([.day], from: startOfYear, to: currentTime)
            return max((components.day ?? 0) + 1, 0)
        case .month:
            // Days elapsed in current month
            return calendar.component(.day, from: currentTime)
        }
    }

    private var currentProgress: Double {
        return Double(elapsedDays) / Double(totalDays)
    }

    private var displayTitle: String {
        let calendar = Calendar.current
        switch mode {
        case .year:
            let year = calendar.component(.year, from: currentTime)
            return "\(year)"
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentTime)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with toggle
            HStack {
                Text(displayTitle)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Spacer()

                // Toggle between Year/Month
                HStack(spacing: 0) {
                    Button(action: {
                        if hapticsEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                        mode = .year
                        triggerAnimation()
                    }) {
                        Text("Year")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(mode == .year ? Color.timeFillDarkBg : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(mode == .year ? Color.timeFillCyan : Color.clear)
                            .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                    }

                    Button(action: {
                        if hapticsEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                        mode = .month
                        triggerAnimation()
                    }) {
                        Text("Month")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(mode == .month ? Color.timeFillDarkBg : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(mode == .month ? Color.timeFillCyan : Color.clear)
                            .cornerRadius(8, corners: [.topRight, .bottomRight])
                    }
                }
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }

            // Heatmap
            CompactSandFillView(
                progress: currentProgress,
                color: .timeFillCyan,
                totalDays: totalDays,
                elapsedDays: elapsedDays,
                shouldAnimate: shouldAnimate,
                forceReAnimate: animationTrigger
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.timeFillCyan.opacity(0.3), lineWidth: 1)
        )
        .onReceive(timer) { time in
            currentTime = time
        }
    }

    private func triggerAnimation() {
        // Delay to ensure mode change propagates before animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animationTrigger.toggle()
        }
    }
}

// Extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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

    return HomeView(showAddEventFromLanding: .constant(false))
        .modelContainer(container)
}
