# Bike Buddy

iOS app for finding nearby bike-share stations, backed by the [CityBikes API](https://api.citybik.es).
Two targets that matter: `BikeBuddy` (SwiftUI app) and `BikeBuddyKit` (models, services,
networking), with unit tests in `BikeBuddyKitTests`.

## Opening a pull request

**The PR title must follow [Conventional Commits](https://www.conventionalcommits.org/).**
CI runs `amannn/action-semantic-pull-request` as the `Validate PR Title` job, and a title
without a type prefix fails the build. This is the single easiest thing to get wrong,
because the commit message being formatted correctly does not help — the action reads the
**PR title**, which is a separate field.

```
feat: search networks by location as well as name
fix: stop the picker crashing on a nameless network
docs: document the PR title convention
```

Allowed types, from `.github/workflows/ci.yml`:

`fix` · `feat` · `docs` · `refactor` · `test` · `ci` · `chore` · `revert`

A scope is optional (`requireScope: false`), so `feat(search): …` and `feat: …` both pass.

### Fixing a bad title needs a new commit

`ci.yml` triggers on `pull_request` without an explicit `types:` list, so it uses the
default `[opened, synchronize, reopened]`. **`edited` is not included**, which means
renaming the PR does *not* re-run the check — it stays red until the next push. After
correcting a title, push a commit (any real change, or `git commit --allow-empty`) to get
a green run.

Better to just open it correctly the first time.

## Building and testing

**Requires Xcode 27 (currently beta.)** `IPHONEOS_DEPLOYMENT_TARGET` is 27.0 and
`StationsListView` uses iOS-27-only SwiftUI APIs such as `toolbarMinimizationBehavior`,
which the stable 26.x SDK cannot compile. Point `DEVELOPER_DIR` at the beta rather than
running `xcode-select`, so the default toolchain stays untouched:

```bash
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild \
  -project ios/BikeBuddy.xcodeproj -scheme BikeBuddy \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

CI handles this by running `build-and-test` on the `xcode-27` runner image while `lint`
stays on `macos-26`. Revisit both once Xcode 27 reaches the GA image.

Do not pipe `xcodebuild` into `tail` or `head` when you care about the result — the
pipeline reports the *last* command's exit status, so a failed test run looks like a pass.
Redirect to a log and check `xcodebuild`'s own status instead.

The other two CI jobs are `SwiftLint --strict --config ios/.swiftlint.yml` (warnings fail
the build) and `python3 scripts/StringsChecker.py -p .` for localization coverage.

## Tests

Unit tests live in `ios/BikeBuddyKitTests` and use **Swift Testing** (`@Test`, `#expect`,
`#require`), not XCTest.

The project has no synchronized file groups, so **a new test file must be added to
`project.pbxproj` by hand** — a `PBXBuildFile`, a `PBXFileReference`, an entry in the
owning `PBXGroup`, and an entry in the test target's `PBXSourcesBuildPhase`. Validate with
`plutil -lint ios/BikeBuddy.xcodeproj/project.pbxproj` afterwards.

`Networks`, `NetworksDataService`, `StationsDataService`, `SettingsService`, and
`CountryCleanupService` are all `@MainActor` singletons. Any suite mutating
`Networks.sharedInstance.list` must be `@Suite(.serialized)` — and note that `.serialized`
only orders tests *within* one suite while Swift Testing parallelizes *across* suites, so
keep all mutation of a given singleton inside a single suite.

## Conventions worth knowing

Model properties from the CityBikes API are optional, and the API genuinely omits fields
depending on the `fields` query in `Constants.CityBikes.NetworksAPI`. Decode with
`decodeIfPresent` and avoid force-unwrapping `name`, `location`, or coordinates — one bad
row must not fail the decode of the whole list.

Network search goes through `Networks.searchThroughList`, which both the FTU and Settings
pickers call, so changes there need no view edits. It matches name and location, and folds
case and accents via the Latin-ASCII transform before comparing — plain
`.diacriticInsensitive` folding leaves stroked letters like `ł` and `ø` alone.

User-facing strings belong in `ios/BikeBuddyKit/Localizable.strings` and are loaded with
`Text("Key", bundle: .bikeBuddyKit)`.
