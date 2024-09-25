# Integration Guide for Developers
The tutorial will guide the developer the detailed flow to understand how to integrate with the iOS Player SDK step by step in your application.
The iOS Player SDK, called UniPlayer provides convenient API about DRM, media controller and a generic graphic user interface. If the generic UI doesn't fit your needs, you can easily customize your own UI through the provided API.

## Develop Environment Requirements
- Xcode 14.0+
- iOS 14+
- Swift 5.0+

|  OS Archs**                 | iOS (arm64) | Simulator (arm64-M1) | Simulator (x86_64-Intel)
|  :----                      | :----:      | :----:               | :----:
| BVPlayer.xcframework	      | ✔           | ✘                    | ✔
| BVPlayer_WOPSE.xcframework	| ✔           | ✔                    | ✔




## Dependencies & Installation
In order to use BV iOS PalyerSDK package, please go in your project settings in Xcode > Package Dependencies tab and click on the "+" icon to add a new dependency.

If you have purchased [Perceptual Streaming Engine (PSE)](https://support.one.blendvision.com/hc/en-us/articles/17051665212313--Beta-Perceptual-Streaming-Engine-PSE-) feature, please use `BVPlayer-latestverions.xcframework` and download the [GPUImage](https://github.com/BlendVision/GPUImage-framework/releases) framework that matches your Xcode version. If not, please use `BVPlayer-latestverions－WOPSE.xcframework` SDK package.

If you want have Google casting feature, please refer [GoogleCast with Guest Mode](https://developers.google.com/cast/docs/ios_sender) to setup.

To add the [BVPLAYER](https://github.com/BlendVision/iOS-Player-SDK) SDK as a dependency to your project, you have two options:
- Swift Package Manager
- Adding the SDK bundle directly
Please refer to [BVPlayer installation guild](https://github.com/BlendVision/iOS-Player-SDK) for more details.

## How to initialize player (with import BV One license key)
```
// Create player configuration
let playerConfig = UniPlayerConfig()
playerConfig.playbackConfig.isAutoplayEnabled = true
playerConfig.licenseKey = "Your license key for playback"
playerConfig.serviceConfig.version = .v2

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
