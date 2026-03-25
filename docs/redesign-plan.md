# BikeBuddy — iOS 26 / Liquid Glass Redesign Plan

## Overview

A phased redesign of BikeBuddy to align with iOS 26 design paradigms (Liquid Glass materials, SwiftUI-first architecture, native system components). The app targets iOS 26 as its minimum deployment target, which unlocks full use of modern APIs and makes all UIKit compatibility layers obsolete.

Phases are ordered so each one is independently shippable. Phase 1 is a pure cleanup with no user-facing changes and is a prerequisite for everything that follows.

---

## Phase 1 — Foundation Cleanup

**Branch:** `chore/remove-uikit-wrappers`
**User-facing changes:** None
**Goal:** Delete all UIKit wrappers, iOS version compat shims, and dead code that accumulated over the app's history. Clears the deck for the visual redesign phases.

### What to remove / replace

| File / Symbol | Reason it exists | Replacement |
|---|---|---|
| `LegacyMapViewRepresentable` (in `MapView.swift`) | iOS 16 MKMapView fallback | Deleted — SwiftUI `Map` is the only path |
| `StationMiniMapView` (in `StationDetailView.swift`) | UIViewRepresentable mini-map | SwiftUI `Map` (Phase 4) |
| `ShareSheet` (UIActivityViewController wrapper) | Pre-`ShareLink` era | `ShareLink` |
| `SafariView` (SFSafariViewController wrapper) | Pre-SwiftUI era | `Link` / `.openURL` |
| `View+OnChange.swift` | iOS 16/17 `onChange` compat shim | Delete file — use `.onChange` directly |
| `ThemeService` in BikeBuddyKit | UIKit nav/tab bar coloring | Accent color asset + SwiftUI `.tint` |
| `#available(iOS 17, *)` branches | Version guards | Dead code — keep only the modern path |
| `MapViewController.swift` | Legacy UIKit map controller | Already superseded by `MapView.swift` |
| Third-party library credits in About | Alamofire, ObjectMapper, etc. not in project | Remove entire section from `SettingsAboutView` |
| `PrimaryButtonStyle` corner radius (4pt) | Inconsistent with system HIG | Update to `.cornerRadius(12)` or `.buttonStyle(.borderedProminent)` |

### Accent color

- Add `BikeBuddyBlue` named color (R:60 G:163 B:220) to `Assets.xcassets`
- Set as global `.accentColor` / `.tint` in `BikeBuddyApp.swift`
- Remove all hardcoded `Color(red:green:blue:)` calls in `MainTabView`, `PrimaryButtonStyle`, `SettingsNumberOfClosestStationsView`

### Privacy Policy

- Replace bundled text file + `PrivacyPolicyView` with a `Link` to a hosted URL
- Remove `PrivacyPolicyView` from `SettingsAboutView`

---

## Phase 2 — Map Redesign

**Branch:** `feat/map-redesign`
**Depends on:** Phase 1
**Goal:** Make the map the flagship Liquid Glass screen. Full-screen immersive layout, system `Marker` annotations with glass callouts, floating availability card on selection, map style toggle.

### Changes

- **`Marker` instead of `Annotation`** — System-rendered `Marker` gets the Liquid Glass callout treatment automatically on iOS 26. Remove custom `Button`-inside-`Annotation` pattern entirely.
- **Glass availability card** — When a `Marker` is selected, a compact glass card floats above the tab bar showing station name, available bikes, and available docks. Tap the card to push to `StationDetailView`. This keeps the user on the map and avoids forcing navigation just to see counts.
- **Full-screen layout** — Map extends edge-to-edge under the glass tab bar. Remove all legacy safe area overrides.
- **"Updated at" label** — Keep as a glass pill (`.regularMaterial` background) anchored to the top of the screen to avoid overlap with the selection card at the bottom.
- **Map style toggle** — Small glass segmented picker (Standard / Satellite) using `MapStyle`. One `@State` var, positioned in the top corner.
- **Remove `annotationsReady` deferred-load hack** — Was needed because SwiftUI `Annotation` view hierarchies were slow to instantiate. `Marker` is system-rendered with none of that overhead.
- **Remove `#available(iOS 17, *)` branch** — `modernMap` becomes `body`, `legacyMap` is deleted.

---

## Phase 3 — Stations List Redesign

**Branch:** `feat/station-list-redesign`
**Depends on:** Phase 1
**Goal:** Replace the UIKit-era fixed-size tile layout with a modern card-style row. Add pull-to-refresh and system empty/loading states.

### Changes

- **New `StationRowView` layout** — Station name on top. Below it, a horizontal row of two compact availability badges: `bicycle` SF Symbol + count, `parkingsign` SF Symbol + count. Replaces the fixed 72×96pt `StationCountTile` boxes.
- **Availability color coding** — Bike badge: green if > 2 available, orange if 1–2, red if 0. Same logic for docks. Derived from existing count data, no API changes needed.
- **`ContentUnavailableView`** — Replaces the custom spinner/empty state combination for both loading and no-data states. Standard iOS 17+ pattern.
- **Remove "Closest Stations" section header** — Redundant with the navigation title. Flatten the list.
- **Pull-to-refresh** — Add `.refreshable` modifier calling `appViewModel.refreshStations()`.
- **Distance display** — Move distance to a trailing label on the row (e.g. "0.3 mi") instead of inline text below the name.

---

## Phase 4 — Station Detail Redesign

**Branch:** `feat/station-detail-redesign`
**Depends on:** Phase 1, Phase 2 (for presentation style decision)
**Goal:** Replace UIViewRepresentable mini-map and plain List layout with a modern full-width map header and glass availability cards.

### Changes

- **Full-width SwiftUI `Map` at top** — Replace `StationMiniMapView` (UIViewRepresentable) with a native SwiftUI `Map` showing a single `Marker` for the station. Interactive (user can pan/zoom). Fixed height (~250pt) with the rest of the screen scrolling below.
- **Glass availability cards** — Two side-by-side `RoundedRectangle` cards with `.regularMaterial` background: one for bikes (large number + `bicycle` icon + "Available Bikes" label), one for docks (large number + `parkingsign` icon + "Available Docks" label). This is the primary information — make it prominent.
- **`ShareLink`** — Replace `ShareSheet` UIActivityViewController wrapper with native `ShareLink(item:subject:message:)`.
- **Directions via `Link`** — Construct a `maps://` URL and open with SwiftUI `Link` or `@Environment(\.openURL)`. No UIKit needed.
- **Sheet presentation from map** — When navigating from a map callout card (Phase 2), present `StationDetailView` as a `.sheet` with `.presentationDetents([.medium, .large])`. The map remains visible in the background. From the station list, continue as a push navigation. Use an enum or environment value to distinguish context.
- **Station name as large title** — Move station name out of the List and into the navigation title (`.navigationTitle`, `.navigationBarTitleDisplayMode(.large)`).

---

## Phase 5 — FTU Redesign

**Branch:** `feat/ftu-redesign`
**Depends on:** Phase 1
**Goal:** Modern glass card onboarding that matches iOS 26 aesthetic. Step indicator. Shared `NetworkPickerView` component.

### Changes

- **Full-bleed background** — `ftuWelcome` and `ftuLocationAccess` images used as full-screen backgrounds (`.scaledToFill`, `.ignoresSafeArea`). Subtle dark overlay for text legibility.
- **Glass card** — Text and button content moved into a `VStack` with `.glassBackground()` (or `.ultraThinMaterial`) anchored to the bottom third of the screen.
- **Step indicator** — `HStack` of small dots (Welcome / Location / Network / Done) at the top of the glass card. Current step highlighted in accent color.
- **`PrimaryButtonStyle` update** — In the FTU context, buttons use `.buttonStyle(.borderedProminent)` with the accent color. Consistent with system HIG.
- **Shared `NetworkPickerView`** — Extract the searchable network list into a standalone view used by both `FTUSelectNetworkView` and `SettingsSelectNetworkView`. Eliminates the duplicated implementation.
- **`FTUFinishedView` animation** — Checkmark appears with a spring scale animation. Small delight moment at completion.

---

## Phase 6 — Settings Polish

**Branch:** `feat/settings-polish`
**Depends on:** Phase 1
**Goal:** Clean up the Settings and About screens. Remove stale content, modernize layout.

### Changes

- **Remove third-party library credits** — Alamofire, ObjectMapper, AlamofireObjectMapper, SVProgressHUD, DZNEmptyDataSet are not in the project. The entire "Third-Party Libraries" section in `SettingsAboutView` should be removed.
- **Privacy Policy as web link** — Replace `PrivacyPolicyView` (loads bundled text file) with a `Link` to a hosted privacy policy URL. Update `SettingsAboutView` accordingly.
- **Network row in Settings** — Show network name and city together (e.g. "Citi Bike — New York, US") instead of just the network name. More informative, same data already available.
- **"Tell Your Friends" as `ShareLink`** — Replace the UIActivityViewController-based share with a native `ShareLink`.
- **Version display** — Clean up version/build format in About. Current: "App Name 1.8.0-59". Consider: "Version 1.8.0 (59)" in secondary color.
- **`.listStyle(.insetGrouped)`** — Verify all Settings list views use consistent list style.

---

## Component Inventory (Post-Redesign)

After all phases complete, the custom component set should be:

| Component | Used in | Notes |
|---|---|---|
| `StationRowView` | `StationsListView` | New badge-based layout (Phase 3) |
| `StationAvailabilityCard` | `StationDetailView`, map callout | Glass card showing bikes/docks (Phases 2, 4) |
| `NetworkPickerView` | FTU, Settings | Extracted shared component (Phase 5) |
| `PrimaryButtonStyle` | FTU | Updated to 12pt radius; Settings uses `.borderedProminent` |
| `BikeBuddyBlue` | App-wide accent | Named color asset (Phase 1) |

All UIKit wrappers (`ShareSheet`, `SafariView`, `StationMiniMapView`, `LegacyMapViewRepresentable`) are deleted by Phase 1/4.

---

## Notes

- **`MapViewController.swift`** — Legacy UIKit file still present in the project. Should be deleted in Phase 1; it is already superseded by `MapView.swift`.
- **Spotlight / Handoff** — `NSUserActivity` integration in `StationDetailView` and `BikeBuddyApp.swift` should be preserved through all phases.
- **Analytics stubs** — `AnalyticsService.pegUserAction()` calls should be preserved in their current locations. The stubs make it easy to wire up a real analytics provider later.
- **Orientation support** — App currently supports all orientations. Review after Phase 3/4 — the new layouts should accommodate landscape, but the fixed-height map header in detail may need adjustment.
- **iPad** — With iOS 26's `tabViewStyle(.sidebarAdaptable)`, consider opting into the sidebar tab pattern on iPad as a Phase 2 or 6 enhancement.
