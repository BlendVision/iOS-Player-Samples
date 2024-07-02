#  Basic Playback With PIP

## Overview


## Usage
To use the PIP functionality, follow these steps:
1. Configure the background modes:
    a. Select your app’s target in Xcode and select the Signing & Capabilities tab.
    b. Click the + Capability button and add the Background Modes capability to the project.
    c. In the Background Modes interface, select the Audio, AirPlay, and Picture in Picture option.
    
2. Configure the audio session:
    Specify the audio session category to the playback category. Enabling this category means your app can play background audio if you’re using the Audio, AirPlay, and Picture in Picture.

```swift
func configureAudioSession() {
    do {
        let session = AVAudioSession.sharedInstance()
        // Configure the app for playback of long-form movies.
        try session.setCategory(.playback)
    } catch {
        // Handle error.
    }
}
```
3. Create player view configuration and enable the PIP feature:

```swift
playerViewConfig().pictureInPictureConfig.isEnabled = true
```
