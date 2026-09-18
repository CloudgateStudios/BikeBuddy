//
//  ScreenshotTests.swift
//  BikeBuddy
//
//  UI test suite that drives app navigation and captures App Store screenshots.
//  Run via: fastlane screenshots
//
//  Screenshots captured (in order):
//   01 – Stations List  (with mock station rows)
//   02 – Station Detail (pushed from list)
//   03 – Map            (pins visible; station selection card if tap succeeds)
//   04 – Networks       (the picker, seeded from ScreenshotMockData)

import XCTest

@MainActor
final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() async throws {
        continueAfterFailure = false
        setupSnapshot(app)
        // Use += to preserve fastlane's required args (-FASTLANE_SNAPSHOT, -AppleLanguages,
        // -AppleLocale, etc.) that setupSnapshot() appended above.
        app.launchArguments += ["UI_TESTING_SCREENSHOTS"]
        // Belt-and-suspenders: also pass as an env var so AppViewModel can read it even
        // if argument parsing behaves differently in Release/non-Debug builds.
        app.launchEnvironment["UI_TESTING_SCREENSHOTS"] = "1"
        app.launch()
    }

    // MARK: - Screenshot tests (run in alphabetical order by Xcode)

    func test01_StationsList() {
        // Wait for station rows to appear (mock data pre-seeded via launch env).
        let firstRow = app.staticTexts[Self.nearestStation].firstMatch
        _ = firstRow.waitForExistence(timeout: 20)
        snapshot("01_StationsList")
    }

    func test02_StationDetail() {
        // Wait for the list to be populated, then tap the first station row.
        let firstRow = app.staticTexts[Self.nearestStation].firstMatch
        guard firstRow.waitForExistence(timeout: 20) else { return }
        firstRow.tap()
        // Allow the NavigationStack push animation to complete.
        sleep(2)
        snapshot("02_StationDetail")
    }

    func test03_Map() {
        tapTab("Map")
        // Let map tiles load and markers render.
        sleep(4)

        // Try to tap a station marker so the selection card slides up.
        // In iOS 17+ SwiftUI Map, Markers are accessible as otherElements
        // keyed by their title string.
        // Only stations the grid leaves unclustered surface as tappable markers, so
        // try several. A miss just means no selection card, which is still a usable
        // shot of the map.
        let markerNames = [
            Self.nearestStation,
            "W 41 St & 8 Ave",
            "W 45 St & 8 Ave",
            "W 40 St & 7 Ave"
        ]
        for name in markerNames {
            // Markers can surface as otherElements OR buttons depending on iOS version.
            let asOther = app.otherElements[name].firstMatch
            let asButton = app.buttons[name].firstMatch
            if asOther.exists {
                asOther.tap()
                sleep(2) // Wait for selection card spring animation
                break
            } else if asButton.exists {
                asButton.tap()
                sleep(2)
                break
            }
        }

        snapshot("03_Map")
    }

    func test04_Networks() {
        tapTab("Settings")
        sleep(1)

        // Settings > Network opens the shared picker. Its list is seeded in
        // ScreenshotMockData, so this needs no network and always looks the same.
        let networkRow = app.staticTexts["Network"].firstMatch
        guard networkRow.waitForExistence(timeout: 10) else { return }
        networkRow.tap()

        let firstNetwork = app.staticTexts["ARbike"].firstMatch
        _ = firstNetwork.waitForExistence(timeout: 10)
        sleep(1)
        snapshot("04_Networks")
    }

    // MARK: - Helpers

    /// The closest station to ScreenshotMockData.coordinate, and so the first row in
    /// the list. Named once here because three tests key off it.
    private static let nearestStation = "W 42 St & 8 Ave"

    /// Navigate to a named tab.
    ///
    /// On iPhone, SwiftUI's TabView exposes its items under a `tabBar`
    /// accessibility container.  On iPad with iOS 18+, Apple replaced the
    /// classic bottom bar with a `_UIFloatingTabBar` whose items do NOT form
    /// a `tabBar` accessibility element — they show up as plain `buttons`
    /// directly on the app with `identifier` == SF-symbol name and
    /// `label` == the tab title string.  We try the traditional path first
    /// and fall back to the global button query for iPad.
    private func tapTab(_ label: String) {
        // iPhone: traditional tabBar container
        let tabBarButton = app.tabBars.buttons[label]
        if tabBarButton.exists {
            tabBarButton.tap()
            return
        }
        // iPad iOS 18+: floating tab bar items appear as top-level buttons
        let floatingButton = app.buttons[label].firstMatch
        XCTAssertTrue(floatingButton.waitForExistence(timeout: 5),
                      "Could not find tab '\(label)' in tabBar or floating tab bar")
        floatingButton.tap()
    }
}
