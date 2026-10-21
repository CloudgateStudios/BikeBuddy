//
//  ReviewPromptServiceTests.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import Testing
@testable import BikeBuddy

/// Each test gets its own defaults suite and clock, so nothing here touches the
/// shared app group or any singleton.
@MainActor
struct ReviewPromptServiceTests {

    // MARK: - Helpers

    private final class Clock {
        var now = Date(timeIntervalSince1970: 1_790_000_000)

        func advance(days: Int) {
            now = Calendar.current.date(byAdding: .day, value: days, to: now)!
        }
    }

    private func makeDefaults() -> UserDefaults {
        let suite = "ReviewPromptServiceTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func makeService(defaults: UserDefaults, clock: Clock) -> ReviewPromptService {
        ReviewPromptService(defaults: defaults, now: { clock.now })
    }

    /// Three actions over two days, then past the minimum age: eligible.
    private func makeEngagedService(clock: Clock, defaults: UserDefaults? = nil) -> ReviewPromptService {
        let service = makeService(defaults: defaults ?? makeDefaults(), clock: clock)
        service.recordSignificantAction()
        service.recordSignificantAction()
        clock.advance(days: 1)
        service.recordSignificantAction()
        clock.advance(days: 2)
        return service
    }

    /// Directions, out to Maps, and back.
    private func returnFromDirections(_ service: ReviewPromptService, version: String = "3.2.0", hasLoadError: Bool = false) -> Bool {
        service.recordDirectionsRequested()
        service.appDidEnterBackground()
        return service.consumePromptIfDue(appVersion: version, hasLoadError: hasLoadError)
    }

    // MARK: - Eligibility

    @Test func newUserIsNotEligible() {
        let service = makeService(defaults: makeDefaults(), clock: Clock())

        #expect(!service.isEligible(appVersion: "3.2.0"))
    }

    @Test func engagedUserIsEligible() {
        let service = makeEngagedService(clock: Clock())

        #expect(service.isEligible(appVersion: "3.2.0"))
    }

    @Test func actionsOnASingleDayAreNotEnough() {
        let clock = Clock()
        let service = makeService(defaults: makeDefaults(), clock: clock)
        for _ in 0..<5 { service.recordSignificantAction() }
        clock.advance(days: 5)

        #expect(!service.isEligible(appVersion: "3.2.0"))
    }

    @Test func tooFewActionsAreNotEnough() {
        let clock = Clock()
        let service = makeService(defaults: makeDefaults(), clock: clock)
        service.recordSignificantAction()
        clock.advance(days: 1)
        service.recordSignificantAction()
        clock.advance(days: 5)

        #expect(!service.isEligible(appVersion: "3.2.0"))
    }

    @Test func tooSoonAfterFirstSeenIsNotEnough() {
        let clock = Clock()
        let service = makeService(defaults: makeDefaults(), clock: clock)
        service.recordSignificantAction()
        service.recordSignificantAction()
        clock.advance(days: 1)
        service.recordSignificantAction()

        #expect(!service.isEligible(appVersion: "3.2.0"))
    }

    // MARK: - Prompting

    @Test func promptsOnReturnFromDirections() {
        let service = makeEngagedService(clock: Clock())

        #expect(returnFromDirections(service))
    }

    @Test func doesNotPromptWithoutLeavingTheApp() {
        let service = makeEngagedService(clock: Clock())
        service.recordDirectionsRequested()

        #expect(!service.consumePromptIfDue(appVersion: "3.2.0", hasLoadError: false))
    }

    @Test func doesNotPromptOnAnOrdinaryReturn() {
        let service = makeEngagedService(clock: Clock())
        service.appDidEnterBackground()

        #expect(!service.consumePromptIfDue(appVersion: "3.2.0", hasLoadError: false))
    }

    @Test func doesNotPromptWhenStationsFailedToLoad() {
        let service = makeEngagedService(clock: Clock())

        #expect(!returnFromDirections(service, hasLoadError: true))
    }

    @Test func aReturnClearsThePendingTrip() {
        let service = makeEngagedService(clock: Clock())
        service.recordDirectionsRequested()
        service.appDidEnterBackground()
        _ = service.consumePromptIfDue(appVersion: "3.2.0", hasLoadError: true)

        service.appDidEnterBackground()
        #expect(!service.consumePromptIfDue(appVersion: "3.2.0", hasLoadError: false))
    }

    @Test func promptsOncePerVersion() {
        let defaults = makeDefaults()
        let clock = Clock()
        let service = makeEngagedService(clock: clock, defaults: defaults)

        #expect(returnFromDirections(service))
        #expect(!returnFromDirections(service))
        #expect(returnFromDirections(service, version: "3.3.0"))
    }

    @Test func progressSurvivesARelaunch() {
        let defaults = makeDefaults()
        let clock = Clock()
        _ = makeEngagedService(clock: clock, defaults: defaults)

        let relaunched = makeService(defaults: defaults, clock: clock)
        #expect(relaunched.isEligible(appVersion: "3.2.0"))
    }
}
