//
//  SettingsAboutView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces SettingsAboutTableViewController + SettingsAboutPrivacyPolicyTableViewController.
struct SettingsAboutView: View {

    var body: some View {
        List {
            // MARK: App info
            Section {
                Text(versionString)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            // MARK: Data source
            Section {
                Text(StringsService.getStringFor(key: "SettingsAboutCityBikesLineOne"))
                Text(StringsService.getStringFor(key: "SettingsAboutCityBikesLineTwo"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: Privacy policy
            Section {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Text("Privacy Policy")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(StringsService.getStringFor(key: "SettingsAboutNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsAbout)
        }
    }

    // MARK: - Helpers

    private var versionString: String {
        let name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "BikeBuddy"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        return version == build ? "\(name) \(version)" : "\(name) \(version) (\(build))"
    }
}

// MARK: - Privacy policy view

struct PrivacyPolicyView: View {

    private var privacyPolicyText: String {
        if let path = Bundle.main.path(forResource: Constants.PrivacyPolicyFile.FileName,
                                       ofType: Constants.PrivacyPolicyFile.FileExtension),
           let contents = try? String(contentsOfFile: path, encoding: .utf8) {
            return contents
        }
        return ""
    }

    var body: some View {
        ScrollView {
            Text(privacyPolicyText)
                .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenAboutPrivacyPolicy)
        }
    }
}
