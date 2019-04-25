fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios setup
```
fastlane ios setup
```
Setup the workspace for development

Should be ran by all developers before starting any development
### ios carthageUpdate
```
fastlane ios carthageUpdate
```
Update all dependencies managed by Carthage
### ios testApp
```
fastlane ios testApp
```
Run all the unit tests and generate a nice report

Report will open in default web browser after completing tests
### ios createScreenshots
```
fastlane ios createScreenshots
```
Build and create Screenshots

This action does the following:



- Invoke the Snapfile to create all the screenshots
### ios updateVersionNumber
```
fastlane ios updateVersionNumber
```
Update the version number of all items in the project

Needs to be invoked with version:numberHere
### ios submitToTestFlight
```
fastlane ios submitToTestFlight
```
Create a new build and submit it to TestFlight

This action does the following:



- Increment the build number

- Update all certs and mobile provisioning

- Build the app in 'Release' configuration

- Upload to TestFlight (User needs to pull release trigger)

- Commit the build number change, tag and push to git
### ios uploadMetadata
```
fastlane ios uploadMetadata
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
