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
                .navigationTitle(StringsService.getStringFor(key: "GeneralAppName"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: FTUViewModel.Step.self) { step in
                    switch step {
                    case .locationAccess:
                        FTULocationAccessView()
                    case .selectNetwork:
                        FTUSelectNetworkView()
                    case .finished:
                        FTUFinishedView()
                    default:
                        EmptyView()
                    }
                }
        }
        .environmentObject(ftuViewModel)
    }
}

// MARK: - Welcome step (embedded so it can push via navigationDestination)

private struct WelcomeStep: View {

    @EnvironmentObject var ftuViewModel: FTUViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("ftuWelcome")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)

            Text(StringsService.getStringFor(key: "WelcomeMessageContent"))
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal)

            Spacer()

            NavigationLink(value: FTUViewModel.Step.locationAccess) {
                Text(StringsService.getStringFor(key: "WelcomeGetStartedButton"))
                    .frame(maxWidth: 200)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 40)
        }
        .padding()
    }
}
