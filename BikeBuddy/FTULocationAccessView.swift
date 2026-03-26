//
//  FTULocationAccessView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces FTULocationAccessViewController.
struct FTULocationAccessView: View {

    @EnvironmentObject var ftuViewModel: FTUViewModel

    var body: some View {
        ZStack(alignment: .bottom) {

            // Full-bleed background
            Image("ftuLocationAccess")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Dark scrim for text legibility
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            // Glass card anchored to bottom
            VStack(spacing: 20) {
                FTUStepIndicator(currentStep: .locationAccess)

                Text(StringsService.getStringFor(key: "LocationAccessMessageContent"))
                    .multilineTextAlignment(.center)
                    .font(.body)

                Button(StringsService.getStringFor(key: "LocationAccessButton")) {
                    ftuViewModel.requestLocationAccess()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(StringsService.getStringFor(key: "LocationAccessNotGrantedMessageTitle"),
               isPresented: $ftuViewModel.showLocationDeniedAlert) {
            Button(StringsService.getStringFor(key: "GeneralButtonOK")) {
                ftuViewModel.goToSelectNetwork()
            }
        } message: {
            Text(StringsService.getStringFor(key: "LocationAccessNotGrantedMessageContent"))
        }
    }
}
