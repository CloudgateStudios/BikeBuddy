//
//  ScreenshotTests.swift
//  BikeBuddy
//
//  UI test suite that drives app navigation and captures App Store screenshots.
//  Run via: fastlane screenshots
//
//  Screenshots captured (in order):
//   01 – Stations      (the main screen: map with the stations panel beside or over it)
//   02 – Station Detail(a station chosen — pushed in the sheet, or the card on iPad)
//   03 – Map           (the map given the whole screen)
//   04 – Networks      (the picker, seeded from ScreenshotMockData)
//
//  There is no tab bar to navigate by any more: the map is always on screen and the
//  stations sit on a sheet over it (compact) or in a split view sidebar (regular), so
//  each shot is reached by acting on what is already visible.

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

    func test01_Stations() {
        guard waitForStations() else { return }
        snapshot("01_StationsList")
    }

    func test02_StationDetail() {
        guard waitForStations() else { return }

        app.staticTexts[Self.nearestStation].firstMatch.tap()
        // Allow the push (compact) or the card's spring (regular) to settle.
        sleep(2)
        snapshot("02_StationDetail")
    }

    /// The map is never more than a drag away now, so this shot is the same screen with
    /// the stations panel pushed aside rather than a different tab.
    func test03_Map() {
        guard waitForStations() else { return }

        // Compact: drag the sheet down to its smallest detent so the map has the screen.
        // Regular: the map already has everything the sidebar is not using, so there is
        // nothing to move and the drag is skipped.
        if !isRegularWidth {
            let sheet = app.staticTexts[Self.panelTitle].firstMatch
            if sheet.waitForExistence(timeout: 5) {
                // Coordinate to coordinate: dragging to an element would aim at that
                // element's centre, and the target here is the bottom of the screen.
                let grab = sheet.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                let bottom = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.97))
                grab.press(forDuration: 0.1, thenDragTo: bottom)
                sleep(2)
            }
        }

        snapshot("03_Map")
    }

    func test04_Networks() {
        guard waitForStations() else { return }

        // The network is a control in the panel header now rather than a row inside
        // Settings, so the picker is one tap from the main screen.
        let networkButton = app.buttons[Self.networkButtonIdentifier].firstMatch
        guard networkButton.waitForExistence(timeout: 10) else { return }
        networkButton.tap()

        let firstNetwork = app.staticTexts["ARbike"].firstMatch
        _ = firstNetwork.waitForExistence(timeout: 10)
        sleep(1)
        snapshot("04_Networks")
    }

    // MARK: - Helpers

    /// The closest station to ScreenshotMockData.coordinate, and so the first row in
    /// the list. Named once here because every test keys off it.
    private static let nearestStation = "W 42 St & 8 Ave"

    /// Matches the localized panel title, which is also the sheet's drag handle area.
    private static let panelTitle = "Stations"

    /// Mirrors StationsPanelHeader.networkButtonIdentifier, which the app target owns.
    private static let networkButtonIdentifier = "stationsPanel.networkButton"

    /// Mock data is seeded at launch, so this only waits out the first render.
    @discardableResult
    private func waitForStations() -> Bool {
        app.staticTexts[Self.nearestStation].firstMatch.waitForExistence(timeout: 20)
    }

    /// A split view sidebar exists only at regular width, which is what tells the two
    /// layouts apart from out here without reaching for the device idiom.
    private var isRegularWidth: Bool {
        app.descendants(matching: .any)["stationsPanel.settingsButton"].firstMatch.exists
            && app.windows.firstMatch.frame.width >= 700
    }
}
