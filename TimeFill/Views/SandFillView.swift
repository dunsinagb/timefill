//
//  SandFillView.swift
//  TimeFill
//
//  Created on 2025-10-05
//  GitHub-style heatmap where each box represents a day
//

import SwiftUI

struct SandFillView: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    let size: CGFloat
    let totalDays: Int // Total days from start to target
    let elapsedDays: Int // Days that have passed
    let maxRows: Int? // Optional max rows limit

    @State private var animatedProgress: Double = 0

    init(progress: Double, color: Color, size: CGFloat, totalDays: Int = 100, elapsedDays: Int = 0, maxRows: Int? = nil) {
        self.progress = progress
        self.color = color
        self.size = size
        self.totalDays = max(totalDays, 1)
        self.elapsedDays = elapsedDays
        self.maxRows = maxRows
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Horizontal heatmap grid
            let boxSize: CGFloat = 3 // Much smaller boxes
            let spacing: CGFloat = 1.5

            // Calculate how many boxes fit horizontally
            let maxBoxesPerRow = Int((size - spacing) / (boxSize + spacing))
            let calculatedRows = Int(ceil(Double(totalDays) / Double(maxBoxesPerRow)))
            let rows = maxRows != nil ? min(calculatedRows, maxRows!) : calculatedRows

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
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

            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }

}

// Compact version for list items - battery style
struct CompactSandFillView: View {
    let progress: Double
    let color: Color
    let totalDays: Int
    let elapsedDays: Int
    let shouldAnimate: Bool
    var forceReAnimate: Bool = false

    @State private var animatedProgress: Double = 0
    @State private var hasAnimated = false

    var body: some View {
        HStack(spacing: 4) {
            // Battery outline
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 80, height: 24)

                // Fill - animated
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: max(76 * animatedProgress, 0), height: 20)
                    .padding(.leading, 2)
            }

            // Battery tip
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.3))
                .frame(width: 3, height: 12)
        }
        .onAppear {
            // Always set progress immediately on appear (no animation on initial load)
            animatedProgress = progress
            // Only mark as animated if shouldAnimate is true
            if shouldAnimate {
                hasAnimated = true
            }
        }
        .onChange(of: shouldAnimate) { oldValue, newValue in
            // When trigger changes from false to true, animate
            if !oldValue && newValue {
                // Start from 0 for re-animation
                animatedProgress = 0
                withAnimation(.spring(response: 2.5, dampingFraction: 0.8)) {
                    animatedProgress = progress
                }
                hasAnimated = true
            } else if oldValue && !newValue {
                // Reset flag but keep visual progress
                hasAnimated = false
            }
        }
        .onChange(of: forceReAnimate) { _, _ in
            // Force re-animation when triggered with same delay as initial animation
            animatedProgress = 0
            // Match the initial animation delay (0.1s) for consistency
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 2.5, dampingFraction: 0.8)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            // After initial animation, update progress instantly without re-animating
            if hasAnimated {
                animatedProgress = newValue
            }
        }
    }
}

// Large version for detail view
struct LargeSandFillView: View {
    let progress: Double
    let color: Color
    let totalDays: Int
    let elapsedDays: Int
    let shouldAnimate: Bool
    var forceReAnimate: Bool = false

    @State private var animatedDays: Int = 0
    @State private var hasAnimated = false

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Much larger boxes for detail view
            let boxSize: CGFloat = 12 // Big boxes
            let spacing: CGFloat = 4
            let maxWidth: CGFloat = 320

            // Calculate how many boxes fit horizontally
            let maxBoxesPerRow = Int((maxWidth - spacing) / (boxSize + spacing))
            let rows = Int(ceil(Double(totalDays) / Double(maxBoxesPerRow)))

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<maxBoxesPerRow, id: \.self) { col in
                            let index = row * maxBoxesPerRow + col

                            if index < totalDays {
                                let isElapsed = index < animatedDays

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isElapsed ? color : Color.white.opacity(0.12))
                                    .frame(width: boxSize, height: boxSize)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(Color.white.opacity(isElapsed ? 0.2 : 0.05), lineWidth: 0.5)
                                    )
                                    .scaleEffect(isElapsed ? 1.0 : 0.85)
                                    .animation(
                                        .spring(response: 2.5, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.01),
                                        value: animatedDays
                                    )
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: maxWidth, alignment: .center)
            .onAppear {
                // If shouldAnimate is already true when view appears,
                // set days immediately without animation
                if shouldAnimate {
                    animatedDays = elapsedDays
                    hasAnimated = true
                }
            }
            .onChange(of: shouldAnimate) { oldValue, newValue in
                // When trigger changes from false to true, animate
                if !oldValue && newValue {
                    animateBoxes()
                } else if oldValue && !newValue {
                    // Reset when shouldAnimate goes back to false
                    hasAnimated = false
                }
            }
            .onChange(of: forceReAnimate) { _, _ in
                // Force re-animation when triggered - reset and re-run animation
                animateBoxes()
            }
            .onChange(of: elapsedDays) { _, newValue in
                // After initial animation, update days instantly without re-animating
                if hasAnimated {
                    animatedDays = newValue
                }
            }

            // Stats row
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(elapsedDays)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(elapsedDays == 1 ? "day passed" : "days passed")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.gray)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(totalDays - elapsedDays)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text((totalDays - elapsedDays) == 1 ? "day left" : "days left")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    Text("complete")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.gray)
                }
            }
        }
    }

    private func animateBoxes() {
        // Reset to 0 first
        animatedDays = 0
        // Then animate to target with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animatedDays = elapsedDays
            hasAnimated = true
        }
    }
}

/*
// Old hourglass code - keeping for reference but not used
extension SandFillView {
    // Creates hourglass outline shape
    private func createHourglassOutline(in size: CGSize) -> Path {
        Path { path in
            let width = size.width
            let height = size.height
            let centerX = width / 2
            let topY = height * 0.05
            let bottomY = height * 0.95
            let neckY = height / 2
            let bulbWidth = width * 0.35
            let neckWidth = width * 0.08

            // Top bulb
            path.move(to: CGPoint(x: centerX - bulbWidth, y: topY))
            path.addLine(to: CGPoint(x: centerX + bulbWidth, y: topY))
            path.addCurve(
                to: CGPoint(x: centerX + neckWidth, y: neckY),
                control1: CGPoint(x: centerX + bulbWidth, y: topY + height * 0.15),
                control2: CGPoint(x: centerX + bulbWidth * 0.5, y: neckY - height * 0.05)
            )

            // Bottom bulb
            path.addCurve(
                to: CGPoint(x: centerX + bulbWidth, y: bottomY),
                control1: CGPoint(x: centerX + bulbWidth * 0.5, y: neckY + height * 0.05),
                control2: CGPoint(x: centerX + bulbWidth, y: bottomY - height * 0.15)
            )
            path.addLine(to: CGPoint(x: centerX - bulbWidth, y: bottomY))
            path.addCurve(
                to: CGPoint(x: centerX - neckWidth, y: neckY),
                control1: CGPoint(x: centerX - bulbWidth, y: bottomY - height * 0.15),
                control2: CGPoint(x: centerX - bulbWidth * 0.5, y: neckY + height * 0.05)
            )

            // Back to top
            path.addCurve(
                to: CGPoint(x: centerX - bulbWidth, y: topY),
                control1: CGPoint(x: centerX - bulbWidth * 0.5, y: neckY - height * 0.05),
                control2: CGPoint(x: centerX - bulbWidth, y: topY + height * 0.15)
            )
            path.closeSubpath()
        }
    }

    // Creates top bulb sand (starts full, empties as progress increases)
    private func createTopSand(in size: CGSize, progress: Double) -> Path {
        Path { path in
            let width = size.width
            let height = size.height
            let centerX = width / 2
            let topY = height * 0.05
            let neckY = height / 2
            let bulbWidth = width * 0.35
            let neckWidth = width * 0.08

            // Remaining sand in top (1.0 - progress means full at start, empty at end)
            let remainingRatio = max(1.0 - progress, 0.0)

            // Always show some sand if there's any remaining
            if remainingRatio > 0 {
                // Top of sand starts higher as it empties
                let sandTopY = topY + (neckY - topY) * progress * 0.9

                // Width gets narrower as sand empties
                let topWidth = bulbWidth * (1.0 - progress * 0.5)

                // Start from top of remaining sand
                path.move(to: CGPoint(x: centerX - topWidth, y: sandTopY))
                path.addLine(to: CGPoint(x: centerX + topWidth, y: sandTopY))

                // Curve down to neck
                path.addCurve(
                    to: CGPoint(x: centerX + neckWidth, y: neckY),
                    control1: CGPoint(x: centerX + topWidth, y: neckY - height * 0.1),
                    control2: CGPoint(x: centerX + neckWidth * 2, y: neckY - height * 0.02)
                )

                // Left side back up
                path.addLine(to: CGPoint(x: centerX - neckWidth, y: neckY))
                path.addCurve(
                    to: CGPoint(x: centerX - topWidth, y: sandTopY),
                    control1: CGPoint(x: centerX - neckWidth * 2, y: neckY - height * 0.02),
                    control2: CGPoint(x: centerX - topWidth, y: neckY - height * 0.1)
                )
                path.closeSubpath()
            }
        }
    }

    // Creates bottom bulb sand (fills as progress increases)
    private func createBottomSand(in size: CGSize, progress: Double) -> Path {
        Path { path in
            let width = size.width
            let height = size.height
            let centerX = width / 2
            let bottomY = height * 0.95
            let neckY = height / 2
            let bulbWidth = width * 0.35
            let neckWidth = width * 0.08

            // Sand accumulation in bottom (starts empty, fills up)
            let fillRatio = min(max(progress, 0.0), 1.0)

            // Always show sand if there's any progress
            if fillRatio > 0 {
                // Bottom of sand rises as it fills
                let sandTopY = bottomY - (bottomY - neckY) * fillRatio * 0.9

                // Width gets wider as sand fills
                let bottomWidth = neckWidth + (bulbWidth - neckWidth) * fillRatio

                // Start from bottom
                path.move(to: CGPoint(x: centerX - bulbWidth, y: bottomY))
                path.addLine(to: CGPoint(x: centerX + bulbWidth, y: bottomY))

                // Curve up to current sand level
                path.addCurve(
                    to: CGPoint(x: centerX + bottomWidth, y: sandTopY),
                    control1: CGPoint(x: centerX + bulbWidth, y: bottomY - height * 0.1),
                    control2: CGPoint(x: centerX + bottomWidth, y: sandTopY + height * 0.05)
                )

                // Top of sand (flat)
                path.addLine(to: CGPoint(x: centerX - bottomWidth, y: sandTopY))

                // Curve back down
                path.addCurve(
                    to: CGPoint(x: centerX - bulbWidth, y: bottomY),
                    control1: CGPoint(x: centerX - bottomWidth, y: sandTopY + height * 0.05),
                    control2: CGPoint(x: centerX - bulbWidth, y: bottomY - height * 0.1)
                )
                path.closeSubpath()
            }
        }
    }
}

// Compact version for list items
struct CompactSandFillView: View {
    let progress: Double
    let color: Color

    var body: some View {
        SandFillView(progress: progress, color: color, size: 100)
    }
}

*/

#Preview {
    VStack(spacing: 30) {
        SandFillView(progress: 0.25, color: .timeFillCyan, size: 100, totalDays: 100, elapsedDays: 25)
        SandFillView(progress: 0.65, color: .timeFillPurple, size: 100, totalDays: 150, elapsedDays: 97)
        SandFillView(progress: 0.95, color: .timeFillYellow, size: 100, totalDays: 50, elapsedDays: 47)
    }
    .padding()
    .background(Color.timeFillDarkBg)
}
