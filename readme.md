# Bike Buddy
![Bike Buddy Icon]
(https://raw.githubusercontent.com/tomarra/Bike-Buddy/master/Bike%20Buddy/Images.xcassets/AppIcon.appiconset/AppIcon%403x.png)

## Overview
A simple iOS app to get the nearest bike sharing stations to you. Works off of the fact that the company Bixi has a similar API for a lot of their bike sharing systems.

## Setup
1. Install xctool
  * `sudo brew install xctool`
2. Install [Fastlane](https://fastlane.tools)
  * `sudo gem install fastlane`
3. Install [Carthage](https://github.com/Carthage/Carthage)
  * `sudo brew install carthage`
4. Install ImageMagick
  * Used for frameit
  * `brew install imagemagick`
5. Download and install device frames for frameit
  * Download the needed frames from [Apple Marketing](https://developer.apple.com/app-store/marketing/guidelines/#images)
  * Place them in ~/.frameit/devices_frames
6. Get the workspace ready
 * `fastlane setup`
7. Open up the project file in Xcode 7

## Third Party Use
* [Alamofire](https://github.com/Alamofire/Alamofire)
