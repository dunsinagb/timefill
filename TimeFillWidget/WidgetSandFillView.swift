//
//  WidgetSandFillView.swift
//  TimeFillWidget
//
//  Sand fill visualizations for widgets
//

import SwiftUI

// MARK: - Widget Battery Fill View
struct WidgetBatteryFill: View {
    let progress: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            // Battery outline
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 80, height: 24)

                // Fill
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: max(76 * progress, 0), height: 20)
                    .padding(.leading, 2)
            }

            // Battery tip
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.3))
                .frame(width: 3, height: 12)
        }
    }
}

// MARK: - Widget Heatmap View
struct WidgetHeatmap: View {
    let totalDays: Int
    let elapsedDays: Int
    let color: Color
    let size: CGFloat

    var body: some View {
        let boxSize: CGFloat = 3
        let spacing: CGFloat = 1.5
        let maxBoxesPerRow = Int((size - spacing) / (boxSize + spacing))
        let rows = Int(ceil(Double(totalDays) / Double(maxBoxesPerRow)))

        VStack(spacing: spacing) {
            ForEach(0..<min(rows, 8), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<maxBoxesPerRow, id: \.self) { col in
                        let index = row * maxBoxesPerRow + col

                        if index < totalDays {
                            let isElapsed = index < elapsedDays

                            RoundedRectangle(cornerRadius: 1)
                                .fill(isElapsed ? color : Color.white.opacity(0.15))
                                .frame(width: boxSize, height: boxSize)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: size, alignment: .leading)
    }
}
