# Bike Buddy

A simple iOS app to find the nearest bike sharing stations to your location, powered by the [CityBikes API](https://api.citybik.es/v2/).

## Requirements

- Xcode 27+
- iOS 27+ deployment target
- Ruby (for Fastlane tooling)

## Repo Structure

```
ios/               Xcode project, app source, and iOS tooling
  BikeBuddy.xcodeproj
  BikeBuddy/       App target
  BikeBuddyKit/    Shared framework
  BikeBuddyKitTests/   Unit tests for BikeBuddyKit (Swift Testing)
  BikeBuddyAppTests/   Unit tests for the app target (Swift Testing)
  BikeBuddyUITests/    Layout and screenshot UI tests
  AppStore/        Raw captures, composed App Store screenshots, compose.py
  fastlane/        Screenshot automation and App Store delivery
design/            Photoshop source files and App Icon templates
scripts/           Utility scripts (localization validation)
docs/              Additional documentation
```

## Setup

1. Install Xcode 27+ from the Mac App Store
2. Install Homebrew dependencies:
   ```sh
   brew install swiftlint
   ```
3. Install Ruby gem dependencies (from the `ios/` directory):
   ```sh
   cd ios
   bundle install
   ```
4. Open the project:
   ```sh
   open ios/BikeBuddy.xcodeproj
   ```

## Fastlane

All Fastlane commands should be run from the `ios/` directory:

```sh
cd ios

# Capture light and dark screenshots into AppStore/captures
bundle exec fastlane screenshots

# Re-copy the last snapshot output into AppStore/captures without re-capturing
bundle exec fastlane collect_captures
```

Then, from the repo root, compose the store images from the captures (see
`ios/AppStore/README.md`):

```sh
python3 ios/AppStore/compose.py
```
