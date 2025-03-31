# BVPlayer iOS SDK Sample Project

This project contains a collection of sample applications demonstrating various features of the BVPlayer iOS SDK.

## Sample Applications

### Basic Playback Examples
- **BasicPlayback**: Demonstrates basic HLS or progressive stream playback functionality
- **BasicPlaybackSPM**: Shows how to integrate the player using Swift Package Manager
- **BasicPlaybackWithCustomView**: Demonstrates how to create a custom player view
- **BasicPlaybackWithPIP**: Shows Picture-in-Picture functionality
- **BasicPlaybackWithThumbnailSeeking**: Demonstrates thumbnail preview during seeking

### Advanced Feature Examples
- **BasicDRMPlayback**: Shows how to play DRM-protected content
- **BasicOfflinePlayback**: Demonstrates offline playback functionality
- **BasicCasting**: Shows how to use Google Cast for screen casting
- **BasicAudioPlayback**: Demonstrates audio playback functionality
- **AnalyticsSample**: Shows how to use analytics features

## Running the Samples

1. Clone this repository
2. Open the sample project you want to run
3. Click the Run button

## Development Notes

### Casting Requirements
If you are using Google Cast SDK (BasicCasting or AdvancedCasting), ensure:
- Use a provisioning profile with Access WiFi Information enabled
- Set the `NSBluetoothAlwaysUsageDescription` key in Info.plist

## Documentation

For detailed SDK documentation and integration guides, please visit:
[BVPlayer iOS SDK Documentation](https://developers.blendvision.com/_/sdk/player/ios/documentation/bvplayer) 
