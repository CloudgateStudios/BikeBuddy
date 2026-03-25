//
//  SettingsAboutView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import SafariServices
import BikeBuddyKit

/// Replaces SettingsAboutTableViewController + SettingsAboutPrivacyPolicyTableViewController.
struct SettingsAboutView: View {

    @State private var safariURL: URL?
    @State private var showSafari = false

    private let thirdPartyItems: [(label: String, url: String)] = [
        ("Alamofire", Constants.ExtneralURL.Alamofire),
        ("ObjectMapper", Constants.ExtneralURL.ObjectMapper),
        ("AlamofireObjectMapper", Constants.ExtneralURL.AFOM),
        ("SVProgressHUD", Constants.ExtneralURL.SVProgressHUD),
        ("DZNEmptyDataSet", Constants.ExtneralURL.DZNEmptyDataSet)
    ]

    var body: some View {
        List {
            // MARK: App info
            Section {
                HStack {
                    Text(UIApplication.appName() + " " + UIApplication.versionBuild())
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }

            // MARK: Data source
            Section {
                Text(StringsService.getStringFor(key: "SettingsAboutCityBikesLineOne"))
                Text(StringsService.getStringFor(key: "SettingsAboutCityBikesLineTwo"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: Third-party libraries
            Section(header: Text("Third Party Libraries")) {
                ForEach(thirdPartyItems, id: \.label) { item in
                    Button {
                        openURL(item.url)
                    } label: {
                        Text(item.label)
                            .foregroundStyle(Color(red: 0/255, green: 122/255, blue: 255/255))
                    }
                }
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
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
        .onAppear {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsAbout)
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            safariURL = url
            showSafari = true
        }
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

// MARK: - SFSafariViewController wrapper

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
