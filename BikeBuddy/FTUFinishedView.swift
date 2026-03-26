//
//  FTUFinishedView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces FTUFinishedViewController.
/// The checkmark icon scales in with a spring animation as a small delight moment.
struct FTUFinishedView: View {

    @EnvironmentObject var ftuViewModel: FTUViewModel
    @State private var checkmarkScale: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {

            // Subtle celebratory gradient background
            LinearGradient(
                colors: [Color("BikeBuddyBlue").opacity(0.18), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            // Animated checkmark centred above the card
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 96))
                .foregroundStyle(Color("BikeBuddyBlue"))
                .scaleEffect(checkmarkScale)
                .padding(.bottom, 280)   // keeps it clear of the glass card

            // Glass card anchored to bottom
            VStack(spacing: 20) {
                FTUStepIndicator(currentStep: .finished)

                Text(StringsService.getStringFor(key: "WelcomeMessageContent"))
                    .multilineTextAlignment(.center)
                    .font(.body)

                Button(StringsService.getStringFor(key: "FTUFinishedButton")) {
                    ftuViewModel.complete()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                checkmarkScale = 1
            }
        }
    }
}
