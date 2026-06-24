# BikeBuddy → iOS 27 Modernization Plan

**Scope:** Full modernization
**Minimum supported OS:** iOS 27 (dropping iOS 26 — no `#available` gating needed)
**Status:** Phase 0 complete — in progress

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

- [ ] Convert `AppViewModel` to `@Observable` (remove 11 `@Published`)
- [ ] Convert `FTUViewModel` to `@Observable` (remove 9 `@Published`)
- [ ] Convert `LocationManager` to `@Observable` (remove 2 `@Published`)
- [ ] Update views: `@StateObject` → `@State` (`BikeBuddyApp`, `StationsListView`, `FTUWelcomeView`)
- [ ] Update views: `@EnvironmentObject` → `@Environment(_.self)` (~9 views)
- [ ] Remove `import Combine` from `AppViewModel.swift` and `LocationManager.swift`
- [ ] Build & verify

## Phase 2 · Concurrency

- [ ] Add `async throws` overload to `NetworksDataService.getAllNetworkData`
- [ ] Migrate `FTUViewModel` off the completion-handler path
- [ ] Remove dead completion-handler APIs + `DispatchQueue.main.async` in `StationsDataService` and `NetworksDataService`
- [ ] Enable `SWIFT_STRICT_CONCURRENCY = complete`
- [ ] Move to Swift 6 language mode; resolve fallout
- [ ] Build & verify

## Phase 3 · iOS 27 SwiftUI adoption

- [ ] `toolbarMinimizeBehavior(.onScrollDown, for: .navigationBar)` on stations list + map
- [ ] Liquid Glass visual pass (`PrimaryButtonStyle`, FTU flow, sheets)
- [ ] **Discretionary:** evaluate swipe actions on station rows — propose only if a genuinely useful action exists (don't invent one)

## Phase 4 · Housekeeping

- [ ] Migrate `StationTests` to Swift Testing (`@Test` / `#expect`)
- [ ] Migrate `BikeBuddyKitTests` to Swift Testing
- [ ] **Discretionary:** replace `LaunchScreen.xib` with a modern launch configuration (cosmetic)
- [ ] Remove unused `SystemConfiguration.framework` link

---

## Notes

- Build at the end of each phase so we never drift far from a compiling state.
- Phase 3's swipe actions and Phase 4's launch-screen swap are the most discretionary — treat as "propose, don't force."
