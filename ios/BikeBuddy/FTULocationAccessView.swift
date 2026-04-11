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
        VStack(spacing: 0) {
            Spacer()

            Image("ftuLocationAccess")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260)
                .padding(.horizontal, 32)

            Spacer()

            // Glass card anchored to bottom
            VStack(spacing: 20) {
                FTUStepIndicator(currentStep: .locationAccess)

                Text(StringsService.getStringFor(key: "LocationAccessMessageContent"))
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Button(StringsService.getStringFor(key: "LocationAccessButton")) {
                    ftuViewModel.requestLocationAccess()
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
