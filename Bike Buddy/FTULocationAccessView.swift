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
        VStack(spacing: 24) {
            Spacer()

            Image("ftuLocationAccess")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)

            Text(StringsService.getStringFor(key: "LocationAccessMessageContent"))
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal)

            Spacer()

            Button(StringsService.getStringFor(key: "LocationAccessButton")) {
                ftuViewModel.requestLocationAccess()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 40)
        }
        .padding()
        .navigationTitle(StringsService.getStringFor(key: "LocationAccessNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
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
