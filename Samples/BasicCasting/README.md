# Google Cast Integration

The `AppDelegate` class provided here demonstrates the integration of Google Cast (ChromeCast) into an iOS application using the `KKSPlayer` library. Google Cast allows users to stream media content to supported devices like smart TVs and casting devices.

## Important
Mostly HLS + FairPlay is used, but Cast receiver needs DASH + Widevine, so at least additional DASH url is required, and the sender module may take licenseUrl from source config.

## Casting Requirements
- Use a provisioning profile with Access WiFi Information enabled
- The NSBluetoothAlwaysUsageDescription key is set in the info.plist

### iOS Permissions and Discovery

1. Add `NSBonjourServices` to your Info.plist
Specify `NSBonjourServices` in your Info.plist to allow local network discovery to succeed on iOS 14.

You will need to add both `_googlecast._tcp` and `_<your-app-id>._googlecast._tcp` as services for device discovery to work properly.

Update the following example `NSBonjourServices` definition and replace "ABCD1234" with your appID.

2. Add `NSLocalNetworkUsageDescription` to your Info.plist

We strongly recommend that you customize the message shown in the Local Network prompt by adding an app-specific permission string in your app's Info.plist file for the `NSLocalNetworkUsageDescription` such as to describe Cast discovery and other discovery services, like DIAL.

## Key Components

### Import Statements

```swift
import UIKit
import KKSPlayer
import GoogleCast
```

- `UIKit`: The fundamental framework for building iOS applications.

- `KKSPlayer`: A library for media playback in the application.

- `GoogleCast`: The Google Cast SDK for integrating casting functionality.

### AppDelegate Class

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // ...
}
```

The `AppDelegate` class conforms to the `UIApplicationDelegate` protocol and serves as the entry point for the application. It's where you typically set up and configure various components during app launch.

### application(_:didFinishLaunchingWithOptions:)

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // ...
}
```

This method is called when the application finishes launching. In this case, it performs the following tasks:

- Initializes the Google Cast integration with `CastManager.initializeCasting()`.

- Sets up logging for Google Cast with `GCKLogger.sharedInstance().delegate = self`.

### GCKLoggerDelegate Extension

```swift
extension AppDelegate: GCKLoggerDelegate {
    public func log(fromFunction function: UnsafePointer<Int8>, message: String) {
        print("ChromeCast Log: \(function) \(message)")
    }
}
```

This extension conforms to the `GCKLoggerDelegate` protocol, which allows you to handle and log messages generated by Google Cast. In this implementation, log messages from Google Cast are printed with additional information such as the function name and the message itself.

## Usage

To use this code in your iOS application:

1. Ensure that you have the required dependencies (`KKSPlayer` and `GoogleCast`) properly integrated into your project.

2. Set up your project's configurations related to Google Cast (e.g., application ID).

3. Initialize the Google Cast integration in the `AppDelegate` as shown in the `application(_:didFinishLaunchingWithOptions:)` method.

4. Handle Google Cast functionality as needed in your app.

### Add the custom data to the Cast Receiver
```swift
sourceConfig.castOptions?.customData = [
    "backgroundImage": SampleAppConfig.backgroundImageOfReceiver
]
```
### Provide a different SourceConfig for casting
For local playback we use a HLS stream and for casting a Widevine protected DASH stream with the same content.
```swift!
func makeWidevineConfig(_ sourceConfig: UniSourceConfig) -> UniSourceConfig? {
    let dashUrl = URL(string: "your dash url string")!

    // Create DASHSource as a DASH stream is used for casting
    let castSourceConfig = UniSourceConfig(url: dashUrl, type: .dash)
    castSourceConfig.title = sourceConfig.title
    castSourceConfig.sourceDescription = sourceConfig.sourceDescription
    castSourceConfig.castOptions = sourceConfig.castOptions

    return castSourceConfig
}

    playerConfig.remoteControlConfig.prepareSource = { type, sourceConfig in
    switch type {
    case .cast:
        // Create a different source for casting
        return WidevineMaker().makeWidevineConfig(sourceConfig)
    }
}
```
### Change the Cast Application Id
```swift
let castManagerOptions = CastManagerOptions()
castManagerOptions.applicationId = "12345678" // Replace "12345678" with your appID
CastManager.initializeCasting(options: castManagerOptions)
```