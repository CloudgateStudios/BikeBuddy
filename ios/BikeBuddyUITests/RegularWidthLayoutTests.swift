//
//  RegularWidthLayoutTests.swift
//  BikeBuddy
//
//  The split view flow, measured the way DuoLayoutTests measures the sheet.
//
//  This is the layout an unfolded iPhone Duo gets. Its inner display is 669pt wide,
//  which lands in the regular size class, so unfolding the phone swaps the stations
//  sheet for the sidebar-and-map split view — a different layout reached by a gesture
//  no test can perform, because nothing in simctl, CoreSimulator or XCUITest changes
//  fold state as of Xcode 27.1.
//
//  So the flow is covered here instead, on the devices that do reach it. Run it on the
//  narrowest regular-width simulator available as well as the widest: at 744pt an iPad
//  mini is the closest thing to the Duo's 669pt, and a split view is at its most
//  cramped — and most likely to overlap itself — when the two columns are fighting
//  over the least room.
//
//  The assertion that earns this suite its keep is `assertInsideDetailPane`. The map
//  once ignored the safe area on every edge, which let it and the selection card
//  riding in its bottom inset run underneath the sidebar; the card's leading half,
//  including the station's name, was simply not visible. It looked like a rendering
//  glitch and was a layout one, and only a frame comparison catches it.

import XCTest

@MainActor
final class RegularWidthLayoutTests: XCTestCase {

    let app = XCUIApplication()

    /// Below this the app is in the compact layout, which DuoLayoutTests covers.
    /// Every regular-width simulator is comfortably above it and the Duo's cover
    /// display, at 678pt in landscape, is comfortably below.
    private static let regularWidthFloor: CGFloat = 700

    private static let minimumEdgeClearance: CGFloat = 8
    private static let minimumTouchTarget: CGFloat = 44

    override func setUp() async throws {
        continueAfterFailure = true

        app.launchArguments += ["UI_TESTING_SCREENSHOTS"]
        app.launchEnvironment["UI_TESTING_SCREENSHOTS"] = "1"
        app.launch()

        try skipUnlessRegularWidth()
    }

    override func tearDown() async throws {
        XCUIDevice.shared.orientation = .portrait
    }

    // MARK: - Tests

    /// The split view is actually a split view: a sidebar that does not span the
    /// window, and a map beside it rather than under it.
    func testSplitViewHasASidebarAndADetailPane() throws {
        forEachOrientation { name in
            attachScreenshot("split-view-\(name)")

            let window = app.windows.firstMatch.frame
            guard let sidebar = sidebarFrame() else {
                XCTFail("no station rows to measure the sidebar from in \(name)")
                return
            }

            XCTAssertLessThan(sidebar.maxX, window.width * 0.75,
                              "the sidebar fills the window in \(name); this is not a split view")
            XCTAssertLessThan(sidebar.minX - window.minX, 40,
                              "the sidebar is not against the leading edge in \(name)")
        }
    }

    /// The panel header in the sidebar, which is narrower here than the sheet ever is.
    func testSidebarHeaderStaysReachable() throws {
        forEachOrientation { name in
            attachScreenshot("sidebar-header-\(name)")

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

    /// The map's controls float over the detail pane, and must stay in it.
    func testMapControlsStayInsideTheDetailPane() throws {
        forEachOrientation { name in
            attachScreenshot("map-controls-regular-\(name)")

            for identifier in [Self.locationButton, Self.styleButton] {
                let button = app.buttons[identifier].firstMatch
                guard button.waitForExistence(timeout: 5) else {
                    XCTFail("\(identifier) is missing in \(name)")
                    continue
                }
                assertClearOfEdges(button, label: "\(identifier) in \(name)")
                assertInsideDetailPane(button, label: "\(identifier) in \(name)")
                assertTouchTarget(button, label: "\(identifier) in \(name)")
            }
        }
    }

    /// Selecting a station puts its card over the map. The card is the whole of the
    /// station's detail in this layout, so losing any of it behind the sidebar loses
    /// content, not just polish.
    func testSelectionCardClearsTheSidebar() throws {
        XCUIDevice.shared.orientation = .portrait
        sleep(1)

        let row = app.staticTexts[Self.nearestStation].firstMatch
        guard row.waitForExistence(timeout: 10) else {
            XCTFail("no station rows to select")
            return
        }
        row.tap()
        sleep(2)

        forEachOrientation { name in
            attachScreenshot("selection-card-\(name)")

            let directions = app.buttons[Self.directionsLabel].firstMatch
            guard directions.waitForExistence(timeout: 5) else {
                XCTFail("the selection card has no Directions button in \(name)")
                return
            }

            assertWithinScreen(directions, label: "card Directions in \(name)")
            assertInsideDetailPane(directions, label: "card Directions in \(name)")

            let close = app.buttons[Self.closeCardLabel].firstMatch
            if close.exists {
                assertWithinScreen(close, label: "card close button in \(name)")
                assertInsideDetailPane(close, label: "card close button in \(name)")
                assertTouchTarget(close, label: "card close button in \(name)")
            }
        }
    }

    /// Settings is a sheet over the split view here rather than over another sheet.
    func testSettingsSheetCanAlwaysBeDismissed() throws {
        forEachOrientation { name in
            let gear = app.buttons[Self.settingsButton].firstMatch
            guard gear.waitForExistence(timeout: 5) else {
                XCTFail("settings button is missing in \(name)")
                return
            }
            gear.tap()
            sleep(2)

            attachScreenshot("settings-regular-\(name)")

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

    // MARK: - Orientation sweep

    private func forEachOrientation(_ body: (String) -> Void) {
        for (orientation, name) in Self.orientations {
            XCUIDevice.shared.orientation = orientation
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

    /// The sidebar's extent, taken from the station rows that fill it. Read fresh each
    /// time because it changes with orientation.
    private func sidebarFrame() -> CGRect? {
        let row = app.staticTexts[Self.nearestStation].firstMatch
        guard row.waitForExistence(timeout: 10) else { return nil }

        return row.frame
    }

    /// Fails when the element strays into the sidebar's column.
    private func assertInsideDetailPane(_ element: XCUIElement, label: String) {
        guard let sidebar = sidebarFrame() else {
            XCTFail("could not measure the sidebar to place \(label)")
            return
        }

        XCTAssertGreaterThanOrEqual(element.frame.minX, sidebar.maxX,
                                    "\(label) starts at \(element.frame.minX), inside the sidebar "
                                    + "which runs to \(sidebar.maxX)")
    }

    private func assertWithinScreen(_ element: XCUIElement, label: String) {
        let screen = app.windows.firstMatch.frame

        XCTAssertTrue(screen.contains(element.frame),
                      "\(label) is not fully on screen: \(element.frame) outside \(screen)")
    }

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

        XCTAssertGreaterThanOrEqual(frame.width, Self.minimumTouchTarget, "\(label) is only \(frame.width)pt wide")
        XCTAssertGreaterThanOrEqual(frame.height, Self.minimumTouchTarget, "\(label) is only \(frame.height)pt tall")
    }

    // MARK: - Helpers

    private func skipUnlessRegularWidth() throws {
        let width = app.windows.firstMatch.frame.width

        try XCTSkipUnless(width >= Self.regularWidthFloor,
                          "not a regular-width layout (window is \(width)pt wide)")
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Identifiers

    private static let nearestStation = "W 42 St & 8 Ave"
    private static let doneLabel = "Done"
    private static let directionsLabel = "Directions to Station"
    private static let closeCardLabel = "Close station details"

    private static let networkButton = "stationsPanel.networkButton"
    private static let settingsButton = "stationsPanel.settingsButton"
    private static let styleButton = "map.styleToggle"
    private static let locationButton = "map.locationButton"
}
