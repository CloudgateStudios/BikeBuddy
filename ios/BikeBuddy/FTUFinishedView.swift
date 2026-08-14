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

    @Environment(FTUViewModel.self) private var ftuViewModel
    @State private var checkmarkScale: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 96))
                .foregroundStyle(Color("BikeBuddyBlue"))
                .scaleEffect(checkmarkScale)

            Spacer()

            // Glass card anchored to bottom
            VStack(spacing: 20) {
                FTUStepIndicator(currentStep: .finished)

                Text("WelcomeMessageContent", bundle: .bikeBuddyKit)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    ftuViewModel.complete()
                } label: {
                    Text("FTUFinishedButton", bundle: .bikeBuddyKit)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
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
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                checkmarkScale = 1
            }
        }
    }
}
