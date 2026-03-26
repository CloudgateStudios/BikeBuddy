//
//  FTUSelectNetworkView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces FTUSelectNetworkViewController.
/// Thin wrapper around NetworkPickerView for the FTU context.
struct FTUSelectNetworkView: View {

    @EnvironmentObject var ftuViewModel: FTUViewModel

    var body: some View {
        NetworkPickerView(
            searchPrompt: StringsService.getStringFor(key: "SelectNetworkSearchBarPlaceholder"),
            onSelect: { network in
                ftuViewModel.selectNetwork(network)
            }
        )
        .navigationTitle(StringsService.getStringFor(key: "SelectNetworkNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
