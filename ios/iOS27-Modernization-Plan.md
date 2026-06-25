# BikeBuddy → iOS 27 Modernization Plan

**Scope:** Full modernization
**Minimum supported OS:** iOS 27 (dropping iOS 26 — no `#available` gating needed)
**Status:** Phases 0–4 complete (iOS 27 readiness done) — Phase 5 remaining as post-readiness cleanup

> All work lands on `feat/iOS27-support` (long-lived integration branch) via per-phase PRs. Each phase gets its own working branch and PR targeting `feat/iOS27-support`.

---

## Current State (assessment)

The app is already in strong shape for iOS 27. No hard-deprecated APIs are in use.

| Area | Current state | Action needed |
|---|---|---|
| Deployment target | iOS 26.0 | Bump to 27.0 |
| Swift version | 5.0 | Move to Swift 6 language mode |
| Strict concurrency | Off | Enable `complete` |
| Navigation | `NavigationStack` ✓ | None |
| Map APIs | `Map` + `Marker` ✓ | None |
| `onChange` | 3-parameter form ✓ | None |
| Observation | `ObservableObject` / `@Published` | Migrate to `@Observable` |
| Combine | `import Combine` in 2 files | Remove |
| Concurrency | `@MainActor` + async/await in UI; callbacks in data services | Finish async/await migration |
| Tests | XCTest | Migrate to Swift Testing |
| Launch screen | `LaunchScreen.xib` | Replace with modern config |
| `SystemConfiguration.framework` | Linked but unused | Remove |

---

## Phase 0 · SDK bump & build triage

- [x] Set `IPHONEOS_DEPLOYMENT_TARGET = 27.0` on all targets (app, BikeBuddyKit, both test targets) — all 10 config entries bumped
- [x] Audit every `@State` for the macro-migration trap — **clean**: no view has a custom `init`, and all `@State` declarations are plain (no composed wrappers), so the trap does not apply
- [x] Build, triage warnings/errors, reach green — app + test targets build with **zero errors, zero warnings**
- [x] **Check in with team after this phase**

> **Why the `@State` audit matters:** In SDK 27, `@State` became a macro. A view that declares `@State` with an inline default *and* reassigns it in `init` before other stored properties now fails with `used before being initialized`. The fix is to drop the inline default and assign only in `init` — reordering produces wrong runtime behavior.

## Phase 1 · `@Observable` migration

- [x] Convert `AppViewModel` to `@Observable` (removed 11 `@Published`)
- [x] Convert `FTUViewModel` to `@Observable` (removed 9 `@Published`; `searchText` `didSet` preserved)
- [x] Convert `LocationManager` to `@Observable` (removed 2 `@Published`; dropped `NSObject`-only `ObservableObject` conformance)
- [x] Update views: `@StateObject` → `@State` (`BikeBuddyApp`, `StationsListView`, `FTUWelcomeView`)
- [x] Update views: `@EnvironmentObject` → `@Environment(_.self)` (9 views); `@Bindable` added in `ContentView`, `FTUWelcomeView`, `FTULocationAccessView` for `$`-bindings
- [x] Remove `import Combine` from `AppViewModel.swift` and `LocationManager.swift`
- [x] Build & verify — clean build, **zero errors, zero warnings**

## Phase 2 · Concurrency

- [x] Add `async throws` overload to `NetworksDataService.getAllNetworkData`
- [x] Migrate `FTUViewModel` **and** `NetworkPickerView` off the completion-handler path
- [x] Remove dead completion-handler APIs + `DispatchQueue.main.async` in `StationsDataService` and `NetworksDataService`
- [x] Enable `SWIFT_STRICT_CONCURRENCY = complete` (all 8 configs)
- [x] Move to Swift 6 language mode (`SWIFT_VERSION = 6.0`); resolve fallout
- [x] Build & verify — app + test targets, **zero warnings**

**Concurrency fallout resolved:**
- Isolated the 7 stateful/service singletons to `@MainActor` (`Networks`, `Stations`, `SettingsService`, `CountryCleanupService`, `NetworksDataService`, `StationsDataService`, `AnalyticsService`) and modernized their nested-struct singletons to a direct `static let`. The app's data is main-actor-confined, so this avoids forcing `Sendable` on the model classes.
- `LocationManager` delegates now touch `self.locationManager` instead of sending the non-`Sendable` `manager` parameter into the `@MainActor` task.
- `Station` marked `@unchecked Sendable` (legacy mutable model, effectively main-actor-confined) so `StationRowView`'s `nonisolated` `Equatable` (used by `.equatable()`) can read it race-free.

## Phase 3 · iOS 27 SwiftUI adoption

- [x] `toolbarMinimizeBehavior(.onScrollDown, for: .navigationBar)` on the stations list — **map excluded** (it hides its nav bar and isn't a scroll view, so the modifier is a no-op there)
- [x] Liquid Glass adoption — converted the floating map control pills to `GlassEffectContainer` + `.glassEffect(.regular.interactive(), in: .rect(cornerRadius:))` (the canonical floating-controls use case). Large content cards (FTU cards, detail cards, selection card) intentionally **kept** as `.regularMaterial` per Apple's guidance to limit glass to floating chrome.
- [x] **Skipped — swipe actions:** no genuinely useful row action exists without new feature work (no favorite/delete model), so none added (per "don't invent one")
- [x] **Flagged — `PrimaryButtonStyle` is dead code** (defined, never referenced; FTU buttons use `.buttonStyle(.borderedProminent)`). Left in place; candidate for removal in Phase 4 housekeeping.
- [x] Build & verify — **zero warnings**

## Phase 4 · Housekeeping

- [x] Migrate `StationTests` to Swift Testing (`@Test` / `#expect`) — 4 tests, all passing
- [x] `BikeBuddyKitTests` — removed the empty Xcode-generated stub (tested nothing) rather than migrate boilerplate
- [x] Replace `LaunchScreen.xib` with the modern `UILaunchScreen` Info.plist dict (`UIImageName: launchScreenImage` + new `LaunchBackground` named color matching the xib's blue exactly); xib deleted — removes the last UIKit xib
- [x] Remove unused `SystemConfiguration.framework` link (4 pbxproj entries)
- [x] Remove dead `PrimaryButtonStyle` (carried over from Phase 3's finding)
- [x] Build & verify — **zero warnings**; migrated tests run green

> **Reviewer note:** the launch-screen swap is cosmetic and asset-name-resolved at runtime, so it can't be verified by a build alone — eyeball it on first launch on an iOS 27 sim. The new `LaunchBackground` color is the xib's exact shade (sRGB 62/170/230), distinct from `BikeBuddyBlue` (60/163/220).

## Phase 5 · `Station` → immutable value type (model refactor)

Convert `Station` from a mutable `NSObject` reference type to an immutable `struct`. This is a data-model redesign, not iOS 27 API work, so it's sequenced last and can land independently of the launch timeline.

- [ ] Convert `Station` (and nested `StationExtra`) to a `struct` conforming to `Codable, Identifiable, Sendable` — drops the `@unchecked Sendable` escape hatch added in Phase 2
- [ ] Drop `NSObject` + `MKAnnotation` (only declared, never used — the modern `Map` uses `Marker(coordinate:)`)
- [ ] Replace `setDistanceFromUser` mutation with a functional distance computation in `Stations.getClosestStations` (produce sorted copies rather than mutating in place)
- [ ] Delete `MapView`'s `IdentifiableStation` wrapper — a struct `Station` is `Identifiable` directly
- [ ] Simplify `StationRowView` equality (struct gets synthesized `Equatable`; revisit the custom `==`)
- [ ] Consider the same value-type treatment for `Network` for consistency
- [ ] Build & verify; confirm strict concurrency stays clean with **no** `@unchecked`

**Why separate:** larger blast radius (model API, `Stations` helpers, Map wrapper, tests) and purely a correctness/clarity improvement — keeping it out of the iOS 27 phases keeps those PRs focused and reviewable.

## CI enablement (deferred — `.github/workflows/ci.yml`)

CI currently does **not** run on any of the iOS 27 phase PRs. None of this is required for the code changes; it's needed only to make GitHub Actions actually build/test the iOS 27 work. Tackle as one small PR (likely on `feat/iOS27-support`) when we're closer to merging to `main`.

- [ ] **Trigger:** the workflow fires only on `pull_request` into `main`/`master`; add `feat/iOS27-support` so phase PRs run. (Remove again before/at the final merge to `main`.)
- [ ] **Toolchain:** the `build-and-test` job pins Xcode 26.3 with the `OS=26.2` iOS simulator, but the deployment target is now iOS 27 — bump the runner's Xcode and the `-destination` `OS=` to an iOS 27 runtime, or the build/test step fails for lack of a 27 runtime.
- [ ] **`xcpretty` → `xcbeautify`:** `xcpretty` is unmaintained and predates Swift Testing, so it renders the migrated `StationTests` output poorly (it does **not** affect pass/fail — the job relies on `${PIPESTATUS[0]}`). `xcbeautify` understands Swift Testing output. Swap it in the build and test steps once the runner is actually executing the tests.

---

## Notes

- Build at the end of each phase so we never drift far from a compiling state.
- Phase 3's swipe actions and Phase 4's launch-screen swap are the most discretionary — treat as "propose, don't force."
- Phases 0–4 are the iOS 27 readiness work and gate the launch. Phase 5 is post-readiness cleanup and can be scheduled independently.
