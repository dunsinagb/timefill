//
//  TipJarViewModel.swift
//  TimeFill
//
//  Created on 2025-11-09
//  Tip Jar StoreKit 2 implementation
//

import StoreKit
import SwiftUI

@MainActor
class TipJarViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchaseInProgress = false
    @Published var showThankYou = false
    @Published var isLoading = false
    @Published var loadError: String?

    private var hapticsEnabled: Bool {
        UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    func loadProducts() async {
        isLoading = true
        loadError = nil

        do {
            let ids = ["com.timefill.app.small.tip", "com.timefill.app.medium.tip", "com.timefill.app.big.tip", "com.timefill.app.huge.tip", "com.timefill.app.massive.tip"]
            print("🛒 Requesting products with IDs: \(ids)")

            products = try await Product.products(for: ids)

            print("🛒 Received \(products.count) products")
            for product in products {
                print("  - \(product.id): \(product.displayName) - \(product.displayPrice)")
            }

            // If no products were returned, it means they're not configured in App Store Connect
            if products.isEmpty {
                print("⚠️ No products returned - check App Store Connect")
                loadError = "Tip options are not available yet. Please check back soon!"
            }
        } catch {
            print("❌ Failed to load products:", error)
            print("❌ Error details: \(error.localizedDescription)")
            loadError = "Unable to load tip options. Please try again later."
        }

        isLoading = false
    }

    func purchase(_ product: Product) async {
        purchaseInProgress = true

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if let transaction = checkVerified(verification) {
                    // Successful purchase
                    await transaction.finish()

                    // Trigger haptics if enabled
                    if hapticsEnabled {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }

                    // Show thank you message
                    showThankYou = true

                    // Hide thank you after 3 seconds
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    showThankYou = false
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed:", error)
        }

        purchaseInProgress = false
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) -> T? {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            return nil
        }
    }
}
