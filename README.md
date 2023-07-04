# BV One iOS Player SDK

## Develop Environment Requirements
- Xcode 14.0+
- iOS 14+
- Swift 5.0+

## Dependencies
- [GPUImage_iOS](https://github.com/BlendVision/PSE-framework/releases) `Xcode 14.3.1+ (Swift Version: 5.8.1)`
- [SwiftWebVTT](https://gitlab.kkinternal.com/playback/swiftwebvtt) `1.0.0`
- [HLSParser](https://gitlab.kkinternal.com/playback/hlsparser) `1.0.0`
- [GoogleCast with Guest Mode](https://dl.google.com/dl/chromecast/sdk/ios/GoogleCastSDK-ios-4.7.1_dynamic_beta.xcframework.zip) `4.7.1`

# Integration Guide for Developers
The tutorial will guide the developer the detailed flow to understand how to integrate with the Android Player SDK step by step in your application.
The Android Player SDK, called UniPlayer provides convenient API about DRM, media controller and a generic graphic user interface. If the generic UI doesn't fit your needs, you can easily customize your own UI through the provided API.

## Setup for Developing With the KKSPlayer Framework
### Setup steps
To install one of the dynamic libraries:
1. Download and unzip the appropriate dynamic SDK for your project.
2. Drag the unzipped .framework or .xcframework into your main project in the Xcode project navigator. Check 'Copy all items if needed', and add to all targets.
3. In your Xcode target, under the General tab, select Embed and Sign for KKSPlayer.framework or KKSPlayer.xcframework and [GPUImage_iOS.framework](https://github.com/BlendVision/PSE-framework/releases)

## How to initialize player (with import BOP license key)
```
// Create player configuration
let playerConfig = UniPlayerConfig()
playerConfig.playbackConfig.isAutoplayEnabled = true
playerConfig.key = "Your license key for playback"

// Create player based on player config
player = UniPlayerFactory.create(player: playerConfig)

// Listen to player events
player.add(listener: self)
```
## How to setup common view (UniPlayerView)
```
// Create player view and pass the player instance to it
playerView = UniPlayerView(player: player, frame: .zero)
playerView.translatesAutoresizingMaskIntoConstraints = false
playerView.fullscreenHandler = self

// Listen to UI events
playerView.add(listener: self)
```
## How to get playback session info (Manifests)
API Document: https://docs.one-dev.kkstream.io/api/bv/v0.110.0/ui/elements/index.html#/operations/PublicPlaybackService_GetSessionInfo
```
let headers = [
  "Content-Type": "application/json",
  "x-kk-api-key": "Your API Key"
]

// Config playback session info url
let urlString = "https://api-http.orbit-dev.kkstream.io/bv/playback/v1/sessions/{device_id}"
let deviceId = "123456"

// Replacing
let url = URL(string: urlString.replacingOccurrences(of: "{device_id}", with: deviceId))!

let request = NSMutableURLRequest(url: url,
                                  cachePolicy: .useProtocolCachePolicy,
                                  timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest,
                               completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```
## How to set the source configuration
```
// Create source config
let hlsUrl = "https://xxx/xxx.m3u8"
let sourceConfig = UniSourceConfig(url: hlsUrl, type: .hls)
sourceConfig.title = "Your video title"
sourceConfig.sourceDescription = "Your video description"
```
## How to start playback session
API Document: https://docs.one-dev.kkstream.io/api/bv/v0.110.0/ui/elements/index.html#/operations/PublicPlaybackService_StartSession
```
import Foundation

let headers = [
  "Content-Type": "application/json",
  "x-kk-api-key": "Your API Key"
]

let request = NSMutableURLRequest(url: NSURL(string: "https://api-http.orbit-dev.kkstream.io/bv/playback/v1/sessions/123:start")! as URL,
                                  cachePolicy: .useProtocolCachePolicy,
                                  timeoutInterval: 10.0)
request.httpMethod = "POST"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```
## How to set DRM configuration
```
// Create drm configuration
let fpsConfig = UniFairPlayConfig(licenseUrl: licenseUrl, certificateUrl: certUrl)
fpsConfig.certificateRequestHeaders = "The certificate request headers"
fpsConfig.licenseRequestHeaders = "The license request headers"
sourceConfig.drmConfig = fpsConfig

// Load source config
player.load(sourceConfig: sourceConfig)
```
## How to play/pause
```
player.play()
player.pause()
```
## How to release player
```
player.destroy()
```
## Casting Requirements
> If you are using the Google Cast SDK, make sure the following requirements are met:
- Use a provisioning profile with `Access WiFi Information` enabled
- The `NSBluetoothAlwaysUsageDescription` key is set in the info.plist
