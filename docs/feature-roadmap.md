# BikeBuddy — Feature Roadmap

## Overview

BikeBuddy's core purpose is answering one question as fast as possible: **"Where's the nearest available bike or dock right now?"** The features in this roadmap deepen that value rather than dilute it. Each tier is ordered so earlier work unblocks later work, and every item can ship independently.

**Competitive positioning:** Individual operator apps (Citi Bike, Divvy) are single-network. Transit super-apps (Citymapper, Transit) treat bike-share as a secondary feature. No multi-network bike-share app currently offers great UX — this is BikeBuddy's lane.

---

## Tier 1 — Quick Wins

Small effort, ships fast, immediate user value. These fit in existing files with surgical additions.

---

### QW-1 — Surface Station Address

**User problem:** Users often cannot identify a station by name alone. A secondary address line removes the guesswork.

**What to do:**
- `StationExtra.address` is already decoded from the API. The `streetAddress` computed property in `Station.swift` exists but is commented out — uncomment it.
- Show the address as a secondary line in `StationRowView` and beneath the distance label in `StationDetailView`.
- Include it in the share text (the localization key `StationModelShareAddress` already exists in `Localizable.strings`).

**Files:** `ios/BikeBuddyKit/Station.swift`, `ios/BikeBuddy/StationsListView.swift`, `ios/BikeBuddy/StationDetailView.swift`

---

### QW-2 — Closed Station Badge

**User problem:** A station showing 0 bikes might be empty or shut down for maintenance. Users waste a trip walking to a shuttered station.

**What to do:**
- `StationExtra.renting` and `StationExtra.returning` are already decoded but never shown in the UI.
- Add `isRenting: Bool` and `isReturning: Bool` computed properties to `Station`.
- In `StationRowView`, overlay an "Out of Service" pill (orange or gray) when `!isRenting`.
- In `StationDetailView`, show a prominent warning card above the availability cards when the station is not renting.

**Files:** `ios/BikeBuddyKit/Station.swift`, `ios/BikeBuddy/StationsListView.swift`, `ios/BikeBuddy/StationDetailView.swift`

---

### QW-3 — Faster Refresh + Data Age Indicator

**User problem:** Bike availability changes every few seconds during peak commute hours. At 5-minute intervals, data can be stale enough to mislead decisions.

**What to do:**
- Change `Constants.Timers.RefreshStationsDataDifferenceInSeconds` from `300.0` to `90.0`.
- Add a `TimelineView`-based "Updated X seconds ago" label to `StationsListView`. Color it orange when data is >2 minutes old, red when >5 minutes old.

**Files:** `ios/BikeBuddyKit/Constants.swift`, `ios/BikeBuddy/StationsListView.swift`

---

### QW-4 — Wire Analytics

**User problem (internal):** Every feature on this roadmap requires knowing what users actually do. Without analytics, there is no way to validate that any change had the intended impact.

**What to do:**
- `AnalyticsService.pegUserAction()` is already a stub with 15+ call sites throughout the app. Plug a real SDK into that one method.
- Recommended: **TelemetryDeck** — privacy-preserving by design, no GDPR consent banner required, Swift Package Manager distribution, free tier generous enough for an indie app.

**Files:** `ios/BikeBuddy/AnalyticsService.swift`

**Note:** Ship this first. It gates measurement of every other feature.

---

### QW-5 — Search / Filter in Station List

**User problem:** A commuter who knows they want "the station at Penn Station" cannot find it quickly when it is not the physically closest station to them.

**What to do:**
- Add `@State private var searchText = ""` and `.searchable(text: $searchText)` to `StationsListView`.
- When `searchText` is non-empty, search across all stations (not just the closest N) and sort results by distance. This makes search useful even when the target station falls outside the normal radius.

**Files:** `ios/BikeBuddy/StationsListView.swift`

---

## Tier 2 — Core Enhancements

Medium effort, high value. These are what make BikeBuddy the best bike-share finder on the market.

---

### CE-1 — Home Screen Widget

**User problem:** The most common use case — "is there a bike near me right now?" — currently requires unlocking the phone, opening the app, waiting for a location fix, and waiting for a network refresh. A widget answers the question from the Lock Screen without opening the app.

**What to do:**
- Create a new `BikeBuddyWidget` target. The App Group (`group.com.cloudgatestudios.Bike-Buddy`) and `BikeBuddyKit` framework are already in place — the hard infrastructure is done.
- `TimelineProvider` calls `StationsDataService.getAllStationData()` directly using the stored API URL.
- **Small widget:** single nearest station with bike count, dock count, and timestamp.
- **Medium widget:** top 3 stations as a mini list matching `StationRowView`'s visual language.
- Add a `widgetURL` deep link that opens the station detail or jumps to the map centered on the tapped station.

**Prerequisite:** CE-6 (offline cache) so the widget can show data without a live network call on every refresh.

**Files:** New `BikeBuddyWidget` target; reads App Group UserDefaults and shared container.

---

### CE-2 — Availability Alerts

**User problem:** A user at their desk wants to leave as soon as a dock opens up near their office, or wants to know when bikes are back at their home station. Today they have to keep opening the app and checking manually.

**What to do:**
- Add a new `FavoriteStation` model (`Codable`, stored in App Group UserDefaults) with `bikeThreshold: Int` and `dockThreshold: Int` fields.
- On each `AppViewModel.refreshStations()` completion, check thresholds against fresh data and fire a `UNUserNotificationCenter` local notification when met.
- Add a "Set Alert" button to the actions card in `StationDetailView` (next to Directions and Share). Opens a sheet with steppers for bike and dock thresholds.

**Prerequisite:** CE-3 (favorites) — alerts are most natural when anchored to a saved station.

**Files:** New `FavoriteStation.swift`, `ios/BikeBuddy/AppViewModel.swift`, `ios/BikeBuddy/StationDetailView.swift`

---

### CE-3 — Favorite Stations

**User problem:** Most bike-share users have 2–4 stations they use every day. Sorting purely by distance means a commuter's home station is buried when they check from work.

**What to do:**
- The `favoriteNavBarIcon` and `notFavoriteNavBarIcon` assets already exist in `Images.xcassets` — this was clearly planned.
- Store favorite station IDs in App Group UserDefaults as `[String]`.
- Split `StationsListView` into a "Favorites" section (ordered by distance) and a "Nearby" section.
- Add a toolbar toggle button in `StationDetailView` using the existing assets.

**Files:** `ios/BikeBuddyKit/SettingsService.swift`, `ios/BikeBuddy/StationsListView.swift`, `ios/BikeBuddy/StationDetailView.swift`

---

### CE-4 — "Find a Dock" Mode

**User problem:** Bike-share is a two-step journey: find a bike near you, and find a dock near your destination. BikeBuddy currently only solves step 1.

**What to do:**
- `Stations.getClosestStations()` already accepts arbitrary lat/lon — use a destination coordinate + sort by `availableDocks` instead of `availableBikes`.
- Add a segmented control or toggle to the station list view to switch between "Find a Bike" and "Find a Dock" modes.
- For destination input, use `MKLocalSearch` to resolve an address string to coordinates, or allow the user to drop a pin on the map.

**Files:** `ios/BikeBuddy/StationsListView.swift`, `ios/BikeBuddy/AppViewModel.swift`

---

### CE-5 — Auto-Select Network by Location

**User problem:** New users face a 700-item network picker and often don't know which network name corresponds to their city's bike-share system.

**What to do:**
- After location permission is granted in FTU, compute the distance between the user's coordinate and each `Network.location` coordinate. Select the closest.
- If within ~50km, show a confirmation screen ("We found Citi Bike in New York — is this right?") instead of the full picker.
- Add a "You might be in a different city" banner in `StationsListView` when the user's location is >100km from their configured network's center coordinate. Tapping opens `SettingsSelectNetworkView`.

**Files:** `ios/BikeBuddy/FTUViewModel.swift`, `ios/BikeBuddy/StationsListView.swift`

---

### CE-6 — Offline / Cached Last-Known Data

**User problem:** Mobile connectivity on subway platforms and in parking garages is unreliable. Today, when the API is unreachable, the app shows an error and an empty list.

**What to do:**
- After a successful fetch, encode the `[Station]` array with `JSONEncoder` and write it to the App Group shared container as `stations_cache.json`.
- On a network failure in `AppViewModel.refreshStations()`, load the cache and set `stationsAreStale = true`.
- Show a yellow "Offline — showing data from [timestamp]" banner in `StationsListView` when stale.
- Invalidate the cache when the selected network changes.

**Files:** `ios/BikeBuddy/AppViewModel.swift`, `ios/BikeBuddyKit/StationsDataService.swift`

---

## Tier 3 — Differentiating Features

These are what no competitor currently does well. They define BikeBuddy's market position.

---

### DF-1 — Multi-Network View

**User problem:** BikeBuddy's single-network constraint is its biggest limitation. Some metro areas are served by multiple operators, and users traveling across city boundaries need both.

**What to do:**
- Extend the data layer from a single `[Station]` array to a `[NetworkStationGroup]` collection (network ID + station array).
- Add `secondaryNetworkAPIURL` to `SettingsService`; fetch both networks in parallel with `async let` in `AppViewModel`.
- Inject `networkName: String` into each `Station` at decode time (it is available in the API response wrapper).
- Show network name as a secondary label in `StationRowView`. Use two marker tints on the map.
- Add a "Secondary Network" option to Settings. Start with exactly two networks before generalizing.

**Files:** `ios/BikeBuddy/AppViewModel.swift`, `ios/BikeBuddyKit/Stations.swift`, `ios/BikeBuddyKit/Station.swift`, `ios/BikeBuddyKit/SettingsService.swift`

---

### DF-2 — E-Bike Availability

**User problem:** Whether e-bikes are available is a major decision factor for longer trips or hilly routes. BikeBuddy shows total bikes with no breakdown, forcing users to open the operator's native app.

**What to do:**
- `Network.gbfsHref` is already decoded. GBFS `station_status.json` provides `num_ebikes_available` at the station level.
- Add a `GBFSDataService` in BikeBuddyKit that fetches `{gbfsHref}/station_status.json` and decodes a minimal model.
- After loading CityBikes data, conditionally fetch GBFS if `gbfsHref` is present, and merge by matching `station_id` to `StationExtra.uid`.
- Show a lightning bolt badge alongside the bike count in `StationRowView` and `StationDetailView` when `ebikesAvailable != nil`.

**Files:** New `GBFSDataService.swift`, `ios/BikeBuddyKit/Station.swift`, view files.

---

### DF-3 — Siri Shortcuts (App Intents)

**User problem:** A user walking to a station with hands full cannot easily unlock their phone and open the app. "Hey Siri, find me a bike" should just work.

**What to do:**
- Define a `FindNearestBikeIntent: AppIntent` in BikeBuddyKit using the iOS 16+ App Intents framework.
- The intent fetches station data, finds the closest station with `availableBikes > 0`, and returns a spoken response: "The nearest bike is at W 41 St & 8 Ave, 0.2 miles away, 7 bikes available."
- Donate the intent from `StationDetailView` via `IntentDonation` when a user opens a station detail.
- The intent also works in the Shortcuts app, enabling user automations ("When I leave work, find a bike").
- Note: `NSUserActivityTypes` pattern is already established in `Info.plist` — follow the same approach.

**Files:** New `BikeIntents.swift` in BikeBuddyKit, `ios/BikeBuddy/StationDetailView.swift`, `Info.plist`.

---

### DF-4 — Apple Watch App

**User problem:** Checking a Watch while walking is more natural than pulling out a phone. No bike-share app has a good Watch app. The Watch use case is extremely focused: "nearest bike, right now."

**What to do:**
- Create a new Watch App target. Link `BikeBuddyKit` (Station, SettingsService, StationsDataService) — this is why the framework separation exists.
- Use `WCSession.transferCurrentComplicationUserInfo()` to push the top-3 closest stations from the phone to the Watch on each data refresh.
- Watch app: a simple `List` of 3 station rows showing name, distance, bikes, and docks. Tap a row → walking directions via Watch's built-in Maps.
- WidgetKit-based Watch complication showing the bike count at the nearest station.

**Files:** New Watch App target.

---

### DF-5 — Trip Planner

**User problem:** No multi-network app answers "how do I get from A to B using bike-share?" — the question Citymapper answers for transit. This transforms BikeBuddy from a station finder into a journey planner.

**What to do:**
- User enters origin and destination. Find the best start station (nearest to origin with `availableBikes > 0`) and the best end station (nearest to destination with `availableDocks > 0`).
- Use `MKDirections` for walking legs. Estimate cycling time from distance at ~15 km/h.
- Present as a card: "Walk 3 min to [Start Station] → Bike ~8 min → Walk 2 min to [Destination]" with total time.
- Deep-link to Apple Maps for the walking segments via `MKMapItem.openInMaps`.

**Prerequisite:** CE-4 (destination input infrastructure).

---

## Tier 4 — Future

Bigger bets that require additional infrastructure or platform capabilities.

| ID | Feature | Description | Notes |
|---|---|---|---|
| FM-1 | Live Activities | Dynamic Island tracks a walk to a station, updating the bike count in real time | Requires ActivityKit; `NSLocationAlwaysUsageDescription` already in `Info.plist` |
| FM-2 | Pricing Awareness | Show pricing/membership info per network next to station data | CityBikes API has no pricing; requires a curated JSON feed maintained separately |
| FM-3 | Crowdsourced Reports | Users report "flat tires" or "broken dock" visible to nearby users for 2 hours | Requires a backend (Firebase/Supabase); BikeBuddy's first server-side dependency |
| FM-4 | Travel Mode | Detect significant location change → suggest switching to local network | Lightweight banner version needs only `WhenInUse` location; full version needs `Always` |

---

## Implementation Sequence

```
Now (days) — ship in any order after QW-4:
  QW-4  Analytics             ← ship first; gates measurement of everything else
  QW-1  Station address
  QW-2  Closed station badge
  QW-3  Faster refresh
  QW-5  Search

Sprint 1 (2–4 weeks):
  CE-3  Favorites             ← prerequisite for CE-2
  CE-2  Availability alerts
  CE-5  Auto-select network
  CE-6  Offline cache         ← prerequisite for CE-1 Widget

Sprint 2 (4–8 weeks):
  CE-1  Home screen widget    ← highest-ROI visible feature
  DF-3  Siri shortcuts
  CE-4  Find a dock

Sprint 3 (8–16 weeks):
  DF-2  E-bike availability
  DF-1  Multi-network         ← architectural; plan data layer changes carefully

Future:
  DF-4  Apple Watch
  DF-5  Trip planner
  FM-1  Live Activities
  FM-2  Pricing
  FM-3  Crowdsourced reports
  FM-4  Travel mode
```

---

## Critical Files

| File | Why it matters |
|---|---|
| `ios/BikeBuddyKit/Station.swift` | All model additions land here first (address, e-bike counts, renting/returning flags) |
| `ios/BikeBuddyKit/Constants.swift` | Central registry for settings keys, timer values, analytic event names |
| `ios/BikeBuddy/AppViewModel.swift` | All new app-level state as `@Published` properties; single source of truth |
| `ios/BikeBuddyKit/SettingsService.swift` | All persistence via App Group suite — Widget and Watch extensions read this too |
| `ios/BikeBuddy/StationDetailView.swift` | Primary action surface; favorites toggle, alert button, Siri donation all extend the existing actions card |

---

## Notes

- **App Group entitlement** (`group.com.cloudgatestudios.Bike-Buddy`) is already declared in `BikeBuddy.entitlements` and used by `SettingsService`. The Widget (CE-1) and Watch (DF-4) targets get this for free.
- **`favoriteNavBarIcon` / `notFavoriteNavBarIcon`** assets already exist in `Images.xcassets` — CE-3 (Favorites) was clearly planned by a previous pass.
- **`StationExtra.renting` / `StationExtra.returning`** are already decoded from the API — QW-2 is purely a UI change with no API work.
- **`Network.gbfsHref`** is already decoded — DF-2 (e-bikes) does not require CityBikes API changes, only a new GBFS fetch.
- **Analytics stubs** — `AnalyticsService.pegUserAction()` is called in 15+ places. QW-4 is one file change that activates all of them simultaneously.
