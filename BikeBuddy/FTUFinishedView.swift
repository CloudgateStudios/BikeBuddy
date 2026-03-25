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
struct FTUFinishedView: View {

    @EnvironmentObject var ftuViewModel: FTUViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color(red: 60/255, green: 163/255, blue: 220/255))

            Text(StringsService.getStringFor(key: "WelcomeMessageContent"))
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal)

            Spacer()

            Button(StringsService.getStringFor(key: "FTUFinishedButton")) {
                ftuViewModel.complete()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 40)
        }
        .padding()
        .navigationTitle(StringsService.getStringFor(key: "FTUFinishedNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
