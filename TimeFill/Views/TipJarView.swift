//
//  TipJarView.swift
//  TimeFill
//
//  Created on 2025-11-09
//  Tip Jar UI with StoreKit 2
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TipJarViewModel()
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    // Custom descriptions for each tip level
    private let tipDescriptions: [String: String] = [
        "com.timefill.app.small.tip": "Helps with server costs.",
        "com.timefill.app.medium.tip": "Really helps with server costs.",
        "com.timefill.app.big.tip": "WOW! Awesome! Thanks!",
        "com.timefill.app.huge.tip": "YOU absolute LEGEND!",
        "com.timefill.app.massive.tip": "A Loss For Words. Speechless"
    ]

    var body: some View {
        ZStack {
            // Dark background matching TimeFill theme
            Color.timeFillDarkBg
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Icon - Heart with gradient
                Image(systemName: "heart.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF5757"), // Red
                                Color(hex: "#FF006E"), // Pink
                                Color(hex: "#8338EC")  // Purple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 16)

                // Main heading - "Time" in white, "Fill" in cyan
                VStack(spacing: 6) {
                    HStack(spacing: 0) {
                        Text("Support Time ")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("Fill")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.timeFillCyan)
                    }

                    Text("Enjoying the app?")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }

                // Description text
                Text("Every tip helps keep Time Fill free and ad-free for everyone. Your support means the world!")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .lineLimit(2)

                // Tip options
                VStack(spacing: 10) {
                    if viewModel.isLoading {
                        // Loading state - only shown while actively loading
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(Color.timeFillCyan)
                                .scaleEffect(1.1)

                            Text("Loading tip options...")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.vertical, 30)
                    } else if let error = viewModel.loadError {
                        // Error or no products state
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.white.opacity(0.3))

                            Text(error)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)

                            Button(action: {
                                Task {
                                    await viewModel.loadProducts()
                                }
                            }) {
                                Text("Try Again")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.timeFillCyan)
                                    )
                            }
                        }
                        .padding(.vertical, 30)
                    } else {
                        // Products loaded successfully
                        ForEach(viewModel.products.sorted(by: { $0.price < $1.price })) { product in
                            TipButton(
                                product: product,
                                description: tipDescriptions[product.id] ?? "",
                                isLoading: viewModel.purchaseInProgress
                            ) {
                                Task {
                                    await viewModel.purchase(product)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)

                Spacer()
            }
            .padding(.vertical, 8)

            // Thank you overlay
            if viewModel.showThankYou {
                ThankYouOverlay()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if hapticsEnabled {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Settings")
                            .font(.system(.body, design: .rounded))
                    }
                    .foregroundStyle(Color.timeFillCyan)
                }
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}

// MARK: - Tip Button Component
struct TipButton: View {
    let product: Product
    let description: String
    let isLoading: Bool
    let onTap: () -> Void
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    var body: some View {
        Button(action: {
            if hapticsEnabled {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            onTap()
        }) {
            HStack(spacing: 12) {
                // Left side - Title and description
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }

                Spacer()

                // Right side - Price button (matching TimeFill cyan theme)
                Text(product.displayPrice)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.timeFillCyan)
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.timeFillCyan.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}

// MARK: - Thank You Overlay
struct ThankYouOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF5757"),
                                Color(hex: "#FF006E"),
                                Color(hex: "#8338EC")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 8) {
                    Text("Thank You!")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Your support keeps Time Fill running!")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.timeFillDarkBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.timeFillCyan.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: Color.timeFillCyan.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview
#Preview {
    TipJarView()
}
