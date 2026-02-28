//
//  MonthProgressWidgetView.swift
//  TimeFillWidget
//
//  Medium widget showing month progress as a dot grid
//

import SwiftUI
import WidgetKit

struct MonthProgressWidgetView: View {
    let entry: CalendarEntry

    private var calendar: Calendar { Calendar.current }

    private var totalDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: entry.date)!.count
    }

    private var currentDay: Int {
        calendar.component(.day, from: entry.date)
    }

    private var daysRemaining: Int {
        totalDaysInMonth - currentDay
    }

    private var percentComplete: Int {
        Int((Double(currentDay) / Double(totalDaysInMonth)) * 100)
    }

    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: entry.date)
    }

    private let columns = 8

    private var rows: Int {
        Int(ceil(Double(totalDaysInMonth) / Double(columns)))
    }

    private let cyan = Color(hex: "#36C2FF")
    private let dimText = Color(hex: "#5A5A5A")

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#0F0F0F"),
                    Color(hex: "#0A0A0A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color(hex: "#36C2FF").opacity(0.025), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 140
            )
            .ignoresSafeArea()

            VStack(spacing: 6) {
                // Top row
                HStack(alignment: .firstTextBaseline) {
                    Text(monthLabel)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    Text("Day \(currentDay)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(dimText)
                }

                dotGrid
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom row
                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(daysRemaining)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(daysRemaining == 1 ? "day remaining" : "days remaining")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(dimText)
                    }

                    Spacer()

                    Text("\(percentComplete)%")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(cyan.opacity(0.45))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var dotGrid: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 3
            let totalSpacingH = CGFloat(columns - 1) * spacing
            let totalSpacingV = CGFloat(rows - 1) * spacing
            let dotW = (geo.size.width - totalSpacingH) / CGFloat(columns)
            let dotH = (geo.size.height - totalSpacingV) / CGFloat(rows)
            let dotSize = min(dotW, dotH)

            let gridWidth = CGFloat(columns) * dotSize + totalSpacingH
            let gridHeight = CGFloat(rows) * dotSize + totalSpacingV
            let offsetX = (geo.size.width - gridWidth) / 2
            let offsetY = (geo.size.height - gridHeight) / 2

            let elapsedDays = currentDay

            Canvas { context, size in
                let cyanColor = Color(hex: "#36C2FF")

                for index in 0..<totalDaysInMonth {
                    let col = index % columns
                    let row = index / columns
                    let x = offsetX + CGFloat(col) * (dotSize + spacing)
                    let y = offsetY + CGFloat(row) * (dotSize + spacing)

                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    let path = Circle().path(in: rect)

                    if index < elapsedDays {
                        let rampOpacity = elapsedDays > 1
                            ? 0.35 + 0.65 * (Double(index) / Double(elapsedDays - 1))
                            : 1.0
                        context.fill(path, with: .color(cyanColor.opacity(rampOpacity)))

                        if index == elapsedDays - 1 {
                            let ringRect = rect.insetBy(dx: -1.5, dy: -1.5)
                            let ringPath = Circle().path(in: ringRect)
                            context.stroke(ringPath, with: .color(cyanColor.opacity(0.5)), lineWidth: 1)
                        }
                    } else {
                        context.fill(path, with: .color(.white.opacity(0.07)))
                    }
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Month Progress Medium", as: .systemMedium) {
    MonthProgressWidget()
} timeline: {
    CalendarEntry(date: .now)
}
