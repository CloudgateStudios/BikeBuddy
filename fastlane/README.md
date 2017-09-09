fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>

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
### ios bumpAndArchive
```
fastlane ios bumpAndArchive
```
Create a new archive so its ready for App Store Submission

This action does the following:



- Increment the build number

- Build the app in 'Release' configuration

- Update all certs and mobile provisioning

- Commit the build number change, tag and push to git
### ios uploadMetadata
```
fastlane ios uploadMetadata
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
