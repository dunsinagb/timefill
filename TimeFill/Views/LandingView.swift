//
//  LandingView.swift
//  TimeFill
//
//  Created on 2025-10-08
//

import SwiftUI

struct LandingView: View {
    @Binding var hasSeenLanding: Bool
    var onCreateFirstCountdown: () -> Void
    @State private var animateIn = false
    @State private var batteryProgress: Double = 0
    @State private var showButton = false
    @State private var particlesAnimation = false

    var body: some View {
        ZStack {
            // Background - matches app background
            Color.timeFillDarkBg
                .ignoresSafeArea()

            // Animated particles/dots in background
            if particlesAnimation {
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.timeFillCyan.opacity(0.1))
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: particlesAnimation
                        )
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // App logo - Battery icon with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.timeFillCyan.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(animateIn ? 1.2 : 0.8)
                        .opacity(animateIn ? 0.6 : 0)
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                            value: animateIn
                        )

                    // Battery icon
                    HStack(spacing: 8) {
                        ZStack(alignment: .leading) {
                            // Battery outline
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.timeFillCyan, lineWidth: 6)
                                .frame(width: 140, height: 60)

                            // Battery fill - animated
                            RoundedRectangle(cornerRadius: 9)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.timeFillCyan,
                                            Color.timeFillCyan.opacity(0.7)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(130 * batteryProgress, 0), height: 48)
                                .padding(.leading, 5)
                        }

                        // Battery tip
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.timeFillCyan)
                            .frame(width: 8, height: 30)
                    }
                    .scaleEffect(animateIn ? 1.0 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                }
                .padding(.bottom, 50)

                // App name with stylized text
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Text("Time")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Fill")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.timeFillCyan)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                    Text("Watch time fill beautifully")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(.gray)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                }
                .padding(.bottom, 80)

                Spacer()

                // Get Started button - Circular with text below
                if showButton {
                    VStack(spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                hasSeenLanding = true
                            }
                            // Trigger the Add Event sheet
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onCreateFirstCountdown()
                            }
                        }) {
                            ZStack {
                                // Outer glow ring
                                Circle()
                                    .fill(Color.timeFillCyan.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .blur(radius: 8)

                                // Main button circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.timeFillCyan,
                                                Color.timeFillCyan.opacity(0.85)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.timeFillCyan.opacity(0.5), radius: 16, x: 0, y: 8)

                                // Plus icon
                                Image(systemName: "plus")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }

                        // Text below button
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            // Stagger animations
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateIn = true
            }

            // Animate battery fill
            withAnimation(.easeInOut(duration: 2.5).delay(0.3)) {
                batteryProgress = 0.75
            }

            // Show button
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showButton = true
                }
            }

            // Start particle animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                particlesAnimation = true
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    let delay: Double
    @Binding var animateIn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.timeFillCyan)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.timeFillCyan.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 40)
        .opacity(animateIn ? 1 : 0)
        .offset(x: animateIn ? 0 : -20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateIn)
    }
}

#Preview {
    LandingView(hasSeenLanding: .constant(false), onCreateFirstCountdown: {})
}
