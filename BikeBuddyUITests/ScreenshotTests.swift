//
//  ScreenshotTests.swift
//  BikeBuddy
//
//  UI test suite that drives app navigation and captures App Store screenshots.
//  Run via: fastlane screenshots
//

import XCTest

@MainActor
final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launchArguments = ["UI_TESTING_SCREENSHOTS"]
        app.launch()
    }

    // MARK: - Screenshot tests (run in alphabetical order by Xcode)

    func test01_StationsList() {
        // Wait up to 20 s for station rows or the no-data view to appear
        let listOrEmpty = app.tables.firstMatch
        _ = listOrEmpty.waitForExistence(timeout: 20)
        snapshot("01_StationsList")
    }

    func test02_Map() {
        app.tabBars.buttons.element(boundBy: 1).tap()
        // Let map tiles and markers render
        sleep(3)
        snapshot("02_Map")
    }

    func test03_Settings() {
        app.tabBars.buttons.element(boundBy: 2).tap()
        snapshot("03_Settings")
    }

    func test04_About() {
        app.tabBars.buttons.element(boundBy: 2).tap()
        let aboutCell = app.tables.cells.staticTexts["About"]
        if aboutCell.waitForExistence(timeout: 5) {
            aboutCell.tap()
            snapshot("04_About")
        }
    }
}
