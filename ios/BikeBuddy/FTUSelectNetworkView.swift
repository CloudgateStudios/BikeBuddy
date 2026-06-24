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

    @Environment(FTUViewModel.self) private var ftuViewModel

    var body: some View {
        NetworkPickerView(
            searchPrompt: String(localized: "SelectNetworkSearchBarPlaceholder", bundle: .bikeBuddyKit),
            onSelect: { network in
                ftuViewModel.selectNetwork(network)
            }
        )
        .navigationTitle(Text("SelectNetworkNavBarTitle", bundle: .bikeBuddyKit))
        .navigationBarTitleDisplayMode(.inline)
    }
}
