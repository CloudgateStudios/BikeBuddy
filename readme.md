# Bike Buddy
![Bike Buddy Icon]
(https://raw.githubusercontent.com/tomarra/Bike-Buddy/master/Bike%20Buddy/Images.xcassets/AppIcon.appiconset/AppIcon%403x.png)

## Overview
A simple iOS app to get the nearest bike sharing stations to you. Works off of the fact that the company Bixi has a similar API for a lot of their bike sharing systems.

## Setup
1. Install Homebrew
1. Install Ruby and gems
    * Best way so far for El Capitan is [here](http://railsapps.github.io/installrubyonrails-mac.html). Just don't do the Rails part
1. Install stuff from Homebrew
    * [xctool](https://github.com/facebook/xctool) ][Carthage](https://github.com/Carthage/Carthage) [SwiftLint](https://github.com/realm/SwiftLint)
    * `brew update && brew install xctool && brew install carthage && brew install swiftlint`
1. Install stuff from gems
    * [Fastlane](https://fastlane.tools)
    * `sudo gem install fastlane`
1. Get the workspace ready
    * `fastlane ios setup`
1. Open up the project file in Xcode 7.3

## Third Party Use
* [Alamofire](https://github.com/Alamofire/Alamofire)
* [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)
* [AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper)
* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD)
