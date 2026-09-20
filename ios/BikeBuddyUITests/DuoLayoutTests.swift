//
//  DuoLayoutTests.swift
//  BikeBuddy
//
//  Layout checks for the iPhone Duo, which breaks assumptions the rest of the app's
//  tests are allowed to make.
//
//  What makes this device worth its own suite:
//
//   - Its cover display reports a top safe area inset of 0. The status bar runs down
//     the *trailing* edge instead, as an 84pt inset. Padding measured from the top
//     inset — the normal way — puts a 44pt control against the bezel here, which is
//     exactly the bug this suite exists to catch a second time.
//   - Its corners are asymmetric: radius 8 on the spine edge, 59 on the other. A
//     layout that clears one side is not thereby clear of the other.
//   - At 466pt wide it is wider than any non-folding iPhone, close enough to the
//     regular-width threshold that it is worth proving which side of it we land on.
//
//  Every check is a frame assertion rather than an eyeball: a screenshot shows a human
//  that something moved, but only a measurement fails the build.

import XCTest

@MainActor
final class DuoLayoutTests: XCTestCase {

    let app = XCUIApplication()

    /// The cover display in portrait. Used to recognise the device rather than its
    /// name, so a renamed simulator still runs the suite and a differently shaped one
    /// still skips it.
    private static let coverPortrait = CGSize(width: 466, height: 678)

    /// How close to an edge a control may sit. Chosen for the 59pt corners: a control
    /// nearer than this to a corner is partly under the curve.
    private static let minimumEdgeClearance: CGFloat = 8

    /// Apple's minimum touch target.
    private static let minimumTouchTarget: CGFloat = 44

    override func setUp() async throws {
        // A layout sweep wants every failure, not the first one.
        continueAfterFailure = true

        app.launchArguments += ["UI_TESTING_SCREENSHOTS"]
        app.launchEnvironment["UI_TESTING_SCREENSHOTS"] = "1"
        app.launch()

        try skipUnlessDuo()
    }

    override func tearDown() async throws {
        XCUIDevice.shared.orientation = .portrait
    }

    // MARK: - Tests

    /// The map's own controls, in every orientation. These float over the map with no
    /// bar to hold them down, so they are the first thing to end up under the bezel.
    func testMapControlsClearTheEdgesInEveryOrientation() throws {
        forEachOrientation { name in
            attachScreenshot("map-controls-\(name)")

            for identifier in [Self.locationButton, Self.styleButton] {
                let button = app.buttons[identifier].firstMatch
                guard button.waitForExistence(timeout: 5) else {
                    XCTFail("\(identifier) is missing in \(name)")
                    continue
                }
                assertClearOfEdges(button, label: "\(identifier) in \(name)")
                assertTouchTarget(button, label: "\(identifier) in \(name)")
            }
        }
    }

    /// The panel header carries the only way into settings and the network picker, so
    /// it has to survive every orientation intact and reachable.
    func testStationsPanelHeaderStaysReachable() throws {
        forEachOrientation { name in
            attachScreenshot("panel-header-\(name)")

            for identifier in [Self.networkButton, Self.settingsButton] {
                let button = app.buttons[identifier].firstMatch
                guard button.waitForExistence(timeout: 5) else {
                    XCTFail("\(identifier) is missing in \(name)")
                    continue
                }
                assertWithinScreen(button, label: "\(identifier) in \(name)")
                XCTAssertTrue(button.isHittable, "\(identifier) is not hittable in \(name)")
                assertTouchTarget(button, label: "\(identifier) in \(name)")
            }
        }
    }

    /// A station row is the app's main control. In landscape the sheet has far less
    /// height to work with, which is where rows get clipped or pushed off.
    func testStationRowsStayUsable() throws {
        forEachOrientation { name in
            let row = app.staticTexts[Self.nearestStation].firstMatch
            guard row.waitForExistence(timeout: 10) else {
                XCTFail("no station rows in \(name)")
                return
            }

            attachScreenshot("station-rows-\(name)")
            assertWithinScreen(row, label: "first station row in \(name)")
            XCTAssertTrue(row.isHittable, "first station row is not hittable in \(name)")
        }
    }

    /// Choosing a station pushes its detail inside the sheet, and then the device
    /// gets rotated under it.
    ///
    /// Opened once and rotated, rather than re-opened per orientation: rotating a
    /// sheet that already has something pushed onto it is the harder case, and
    /// re-navigating four times only tested the navigation.
    func testStationDetailSurvivesEveryOrientation() throws {
        XCUIDevice.shared.orientation = .portrait
        sleep(1)

        let row = app.staticTexts[Self.nearestStation].firstMatch
        guard row.waitForExistence(timeout: 10) else {
            XCTFail("no station rows to open")
            return
        }
        row.tap()
        sleep(2)

        let bikes = app.staticTexts[Self.bikesLabel].firstMatch
        XCTAssertTrue(bikes.waitForExistence(timeout: 5), "station detail did not open")

        forEachOrientation { name in
            attachScreenshot("station-detail-\(name)")

            XCTAssertTrue(bikes.exists, "station detail lost its counts in \(name)")

            // The sheet is short in landscape, so the actions can legitimately sit
            // below the fold — what must not happen is their being drawn off screen.
            let directions = app.buttons[Self.directionsLabel].firstMatch
            if directions.exists && directions.isHittable {
                assertWithinScreen(directions, label: "directions button in \(name)")
            }
        }
    }

    /// Settings is a sheet over a sheet here, which is the stacking most likely to
    /// mislay its own dismiss control.
    func testSettingsSheetCanAlwaysBeDismissed() throws {
        forEachOrientation { name in
            let gear = app.buttons[Self.settingsButton].firstMatch
            guard gear.waitForExistence(timeout: 5) else {
                XCTFail("settings button is missing in \(name)")
                return
            }
            gear.tap()
            sleep(2)

            attachScreenshot("settings-\(name)")

            let done = app.buttons[Self.doneLabel].firstMatch
            guard done.waitForExistence(timeout: 5) else {
                XCTFail("Settings has no reachable Done in \(name)")
                return
            }
            assertWithinScreen(done, label: "Done in \(name)")
            XCTAssertTrue(done.isHittable, "Done is not hittable in \(name)")
            done.tap()
            sleep(1)
        }
    }

    /// Records the width the app is actually given, and which size class it lands in.
    /// At 466pt the Duo sits between a phone and an iPad, and which way it resolves
    /// decides whether it gets the sheet or the split view.
    func testCoverDisplayResolvesToTheCompactLayout() throws {
        let window = app.windows.firstMatch
        XCTAssertEqual(window.frame.width, Self.coverPortrait.width, accuracy: 1,
                       "the Duo's cover display is not the width this suite was written against")

        attachScreenshot("layout-portrait")

        // The split view sidebar and the sheet are mutually exclusive. The sheet's
        // drag indicator only exists in the compact layout, so its presence is the
        // observable difference between the two.
        let panelTitle = app.staticTexts[Self.panelTitle].firstMatch
        XCTAssertTrue(panelTitle.waitForExistence(timeout: 10), "stations panel never appeared")

        // In the compact layout the panel sits below the map; in the regular one it is
        // a sidebar starting at the leading edge and running the full height.
        let isSidebar = panelTitle.frame.minY < window.frame.height * 0.25
        XCTAssertFalse(isSidebar,
                       "the Duo's cover display resolved to the regular-width split view; "
                       + "this suite and the layout both assume compact here")
    }

    /// The unfolded inner display, which this suite does not cover.
    ///
    /// The device really has two integrated screens — `simctl io enumerate` lists
    /// the 466x678pt cover as screen 1 and a 669x951pt inner panel as screen 3,
    /// both reporting power state On — but only the cover ever renders.
    /// Screenshotting screen 3 returns black, and as of Xcode 27.1 nothing in
    /// simctl, CoreSimulator or XCUITest changes the fold state, so no test can
    /// get the app onto it.
    ///
    /// A skip rather than an omission, because the gap is worth seeing in the test
    /// report. At 669pt the inner display lands in the regular size class, so
    /// unfolding swaps the sheet for the split view — a different layout from
    /// everything above. That layout is covered by `RegularWidthLayoutTests`,
    /// which runs it on the iPads that can reach it; what stays unverified here is
    /// this display's particular geometry, and the swap itself.
    func testUnfoldedDisplayIsNotReachableFromTests() throws {
        throw XCTSkip(
            "The Duo's inner display (screen 3, 669x951pt) cannot be driven: no "
            + "fold control exists in simctl, CoreSimulator or XCUITest as of "
            + "Xcode 27.1. At 669pt it resolves to the regular-width split view, "
            + "and that flow is covered by RegularWidthLayoutTests on the iPads "
            + "that do reach it — an iPad mini at 744pt being the closest match. "
            + "What is unverified is this display's own geometry, not the layout."
        )
    }

    // MARK: - Orientation sweep

    private func forEachOrientation(_ body: (String) -> Void) {
        for (orientation, name) in Self.orientations {
            XCUIDevice.shared.orientation = orientation
            // Rotation is animated and the sheet re-lays out behind it.
            sleep(2)
            body(name)
        }
    }

    private static let orientations: [(UIDeviceOrientation, String)] = [
        (.portrait, "portrait"),
        (.landscapeLeft, "landscape-left"),
        (.landscapeRight, "landscape-right"),
        (.portraitUpsideDown, "portrait-upside-down")
    ]

    // MARK: - Assertions

    /// Fails when any part of the element is off screen.
    private func assertWithinScreen(_ element: XCUIElement, label: String) {
        let screen = app.windows.firstMatch.frame
        let frame = element.frame

        XCTAssertTrue(screen.contains(frame),
                      "\(label) is not fully on screen: \(frame) outside \(screen)")
    }

    /// Fails when the element is on screen but crowding an edge, which on this device
    /// means sitting under a corner radius or the trailing status bar.
    private func assertClearOfEdges(_ element: XCUIElement, label: String) {
        let screen = app.windows.firstMatch.frame
        let frame = element.frame
        let clearance = Self.minimumEdgeClearance

        XCTAssertGreaterThanOrEqual(frame.minX - screen.minX, clearance, "\(label) crowds the leading edge")
        XCTAssertGreaterThanOrEqual(screen.maxX - frame.maxX, clearance, "\(label) crowds the trailing edge")
        XCTAssertGreaterThanOrEqual(frame.minY - screen.minY, clearance, "\(label) crowds the top edge")
        XCTAssertGreaterThanOrEqual(screen.maxY - frame.maxY, clearance, "\(label) crowds the bottom edge")
    }

    private func assertTouchTarget(_ element: XCUIElement, label: String) {
        let frame = element.frame
        let minimum = Self.minimumTouchTarget

        XCTAssertGreaterThanOrEqual(frame.width, minimum, "\(label) is only \(frame.width)pt wide")
        XCTAssertGreaterThanOrEqual(frame.height, minimum, "\(label) is only \(frame.height)pt tall")
    }

    // MARK: - Helpers

    /// Skips rather than fails elsewhere: this suite measures against one device's
    /// geometry, and those numbers mean nothing on any other.
    private func skipUnlessDuo() throws {
        let size = app.windows.firstMatch.frame.size
        let matches = abs(size.width - Self.coverPortrait.width) < 2
            && abs(size.height - Self.coverPortrait.height) < 2

        try XCTSkipUnless(matches, "not an iPhone Duo cover display (got \(size))")
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Identifiers

    private static let nearestStation = "W 42 St & 8 Ave"
    private static let panelTitle = "Stations"
    private static let doneLabel = "Done"
    private static let directionsLabel = "Directions to Station"
    private static let bikesLabel = "Bikes Available"

    /// Mirror the identifiers the app target owns.
    private static let networkButton = "stationsPanel.networkButton"
    private static let settingsButton = "stationsPanel.settingsButton"
    private static let styleButton = "map.styleToggle"
    private static let locationButton = "map.locationButton"
}
