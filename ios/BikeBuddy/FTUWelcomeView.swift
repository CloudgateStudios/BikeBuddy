//
//  FTUWelcomeView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Root of the First-Time Use flow. Hosts all FTU steps in a single NavigationStack.
/// Replaces FirstTimeUse.storyboard + FTUWelcomeViewController.
struct FTUWelcomeView: View {

    @StateObject private var ftuViewModel = FTUViewModel()

    var body: some View {
        NavigationStack(path: $ftuViewModel.path) {
            WelcomeStep()
                .navigationDestination(for: FTUViewModel.Step.self) { step in
                    switch step {
                    case .welcome:
                        EmptyView()
                    case .locationAccess:
                        FTULocationAccessView()
                    case .selectNetwork:
                        FTUSelectNetworkView()
                    case .finished:
                        FTUFinishedView()
                    }
                }
        }
        .environmentObject(ftuViewModel)
    }
}

// MARK: - Welcome step

private struct WelcomeStep: View {

    @EnvironmentObject var ftuViewModel: FTUViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("ftuWelcome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260)
                .padding(.horizontal, 32)

            Spacer()

            // Glass card anchored to bottom
            VStack(spacing: 20) {
                FTUStepIndicator(currentStep: .welcome)

                Text("WelcomeMessageContent", bundle: .bikeBuddyKit)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink(value: FTUViewModel.Step.locationAccess) {
                    Text("WelcomeGetStartedButton", bundle: .bikeBuddyKit)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                colors: [Color("BikeBuddyBlue").opacity(0.14), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Step indicator

/// Small dot row shown at the top of each FTU glass card.
/// The current step's dot is filled with the accent colour; others are dim.
struct FTUStepIndicator: View {

    let currentStep: FTUViewModel.Step

    private let orderedSteps: [FTUViewModel.Step] = [
        .welcome, .locationAccess, .selectNetwork, .finished
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(orderedSteps.indices, id: \.self) { index in
                Circle()
                    .fill(orderedSteps[index] == currentStep
                          ? Color.accentColor
                          : Color.secondary.opacity(0.35))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
