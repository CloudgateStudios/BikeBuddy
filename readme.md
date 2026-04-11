# Bike Buddy

A simple iOS app to find the nearest bike sharing stations to your location, powered by the [CityBikes API](https://api.citybik.es/v2/).

## Requirements

- Xcode 26+
- iOS 26+ deployment target
- Ruby (for Fastlane tooling)

## Repo Structure

```
ios/               Xcode project, app source, and iOS tooling
  BikeBuddy.xcodeproj
  BikeBuddy/       App target
  BikeBuddyKit/    Shared framework
  BikeBuddyKitTests/
  BikeBuddyUITests/
  fastlane/        Screenshot automation and App Store delivery
design/            Photoshop source files and App Icon templates
app-store-assets/  App Store screenshots by version
scripts/           Utility scripts (localization validation)
docs/              Additional documentation
```

## Setup

1. Install Xcode 26+ from the Mac App Store
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

# Capture new App Store screenshots
bundle exec fastlane screenshots

# Re-frame existing screenshots without re-capturing
bundle exec fastlane framed_screenshots
```
