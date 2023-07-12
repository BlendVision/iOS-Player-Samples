## Available Sample Apps
### Basic
- BasicPlayback: Shows how to set up the BV Player for basic playback of HLS or progressive streams.

## How to integrate the BV Player iOS SDK
When you want to develop an own iOS application using the BV Player iOS SDK read through the following steps.

### Adding the SDK To Your Project
To add the SDK as a dependency to your project, you can add the SDK directly

#### Adding the SDK Directly
When using Xcode, go to the General page or your app target and add the SDK bundle (KKSPlayer.xcframework) under Linked Frameworks and Libraries.

#### Prepare your BV Player license
- Add your BV player license you can also set the license key via the `UniPlayerConfig.key` property when creating a Player instance.

When you do not do this, you'll get a license error when starting the application which contains the player.

## Development Notes
### Casting Requirements
- If you are using the Google Cast SDK (BasicCasting or AdvancedCasting), make sure the following requirements are met:
- Use a provisioning profile with Access WiFi Information enabled
- The NSBluetoothAlwaysUsageDescription key is set in the info.plist

