# BVPlayer iOS/tvOS SDK Integration Guide

BVPlayer is a powerful **iOS** and **tvOS** video player SDK that provides DRM support, media control, and flexible UI customization capabilities.

## Requirements

- Xcode 14.0+
- iOS 14.0+ / tvOS 18.0+
- Swift 5.0+

## Architecture Support

| Architecture | iOS (arm64) | tvOS (arm64) | Simulator (arm64-M1) | Simulator (x86_64-Intel) |
|--------------|-------------|--------------|----------------------|--------------------------|
| BVPlayer     | ✔           | ✔            | ✔                    | ✔                        |

## Installation

Add the SDK to your project using **Swift Package Manager**

> For detailed installation instructions, please refer to [BVPlayer Installation Guide](https://github.com/BlendVision/bvplayer-ios)

## Important Migration Note

If you are upgrading from an older version of the BVPlayer SDK, note the following changes:
- The `key` property in `UniPlayerConfig` is removed; use `licenseKey` instead.
- The `UniPlayerFactory.create(player:)` method is replaced with `createPlayer(playerConfig:analytics:)`.
- Analytics configuration now requires `AnalyticsPlayerConfig` with `AnalyticsConfig` for tokens (replacing `AnalyticsField.token`).
- Refer to the [Migration Guide](/Migrations/analytics_migration_guide.md) for detailed steps.

## Basic Integration

BVPlayer can be integrated into both **iOS** and **tvOS** applications with minimal code changes.  
On tvOS, make sure to optimize UI elements for focus and remote control navigation.

### 1. Initialize Player
```swift
// Create player configuration
let playerConfig = UniPlayerConfig()
playerConfig.playbackConfig.isAutoplayEnabled = true
playerConfig.licenseKey = "your-license-key" // Replace with your license key

// Configure analytics (optional)
let analyticsConfig = AnalyticsPlayerConfig.enabled(
    analyticsConfig: AnalyticsConfig(token: "your-analytics-token"), // Replace with your token
    defaultMetadata: DefaultMetadata(moduleConfig: YourModuleConfig()) // Replace with your module config
)

// Initialize player
let player = UniPlayerFactory.createPlayer(playerConfig: playerConfig, analytics: analyticsConfig)
player.add(listener: self)
```

### 2. Setup Player View
```swift
// Create custom player view
class CustomPlayerView: UIView {
    private let playerLayer: CALayer
    
    init(player: UniPlayer) {
        self.playerLayer = player.playerLayer
        super.init(frame: .zero)
        
        // Add player layer to your view
        layer.addSublayer(playerLayer)
        setupCustomControls()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    private func setupCustomControls() {
        // Add your custom UI controls here
    }
}

// Usage
let customPlayerView = CustomPlayerView(player: player)
customPlayerView.translatesAutoresizingMaskIntoConstraints = false
```

### 3. Configure Source
```swift
// Create source configuration
let sourceConfig = UniSourceConfig(url: "Your HLS URL", type: .hls)
sourceConfig.title = "Video Title"
sourceConfig.sourceDescription = "Video Description"

// Configure DRM if needed
let fpsConfig = UniFairPlayConfig(licenseUrl: "License URL", 
                                  certificateUrl: "Certificate URL")

// Add custom headers for certificate request if needed
fpsConfig.certificateRequestHeaders = [
    "Authorization": "Bearer your-token",
    "Custom-Header": "custom-value"
]

// Add custom headers for license request if needed
fpsConfig.licenseRequestHeaders = [
    "Authorization": "Bearer your-token",
    "Custom-Header": "custom-value"
]

sourceConfig.drmConfig = fpsConfig

// Load source
player.load(sourceConfig: sourceConfig)
```

### 4. Playback Controls
```swift
// Basic controls
player.play()
player.pause()

// Release resources when done
player.destroy()
```

## Offline Playback

BVPlayer SDK provides comprehensive offline playback capabilities, allowing you to:
- Download HLS content for offline viewing
- Manage download tasks (start, pause, resume, cancel)
- Handle DRM-protected content offline
- Monitor download progress and status
- Manage downloaded content lifecycle

The offline playback feature requires proper handling of the following components:
- DownloadManager: Manages all download-related operations
- DownloadContentManager: Handles specific content download and its lifecycle
- DownloadContentManagerListener: Monitors download progress and status changes

### 1. Initialize Download Manager
```swift
// Get shared download manager instance
let downloadManager = DownloadManager.shared

// Get download content manager for specific source
let downloadContentManager = try await downloadManager.downloadContentManager(
    for: sourceConfig,
    identifier: "unique_video_id"
)

// Add listener for download events
downloadContentManager.add(listener: self)
```

### 2. Download Content
```swift
// Start download with default settings
downloadContentManager.download()

// Or start download with specific track selection and config
let tracks = try await downloadContentManager.fetchAvailableTracks()
let downloadConfig = DownloadConfig()
downloadConfig.minimumBitrate = 1000000 // 1Mbps
downloadContentManager.download(tracks: tracks, config: downloadConfig)

// Control download
downloadContentManager.suspendDownload()  // Pause download
downloadContentManager.resumeDownload()   // Resume download
downloadContentManager.cancelDownload()   // Cancel download
```

### 3. Handle Download Events
```swift
extension YourViewController: DownloadContentManagerListener {
    func onContentDownloadFinished(_ event: ContentDownloadFinishedEvent, manager: DownloadContentManager) {
        print("Download finished")
    }
    
    func onContentDownloadProgressChanged(_ event: ContentDownloadProgressChangedEvent, manager: DownloadContentManager) {
        print("Download progress: \(event.progress)")
    }
    
    func onContentDownloadSuspended(_ event: ContentDownloadSuspendedEvent, manager: DownloadContentManager) {
        print("Download suspended")
    }
    
    func onContentDownloadResumed(_ event: ContentDownloadResumedEvent, manager: DownloadContentManager) {
        print("Download resumed")
    }
    
    func onContentDownloadCanceled(_ event: ContentDownloadCanceledEvent, manager: DownloadContentManager) {
        print("Download canceled")
    }
    
    func onDownloadError(_ event: ContentDownloadErrorEvent, manager: DownloadContentManager) {
        print("Download error: \(event.message)")
    }
}
```

### 4. Play Offline Content
```swift
// Create offline source configuration
guard let offlineSourceConfig = downloadContentManager.createOfflineSourceConfig() else {
    return
}

// Load offline source to player
player.load(sourceConfig: offlineSourceConfig)
```

### 5. Manage Downloaded Content
```swift
// Delete downloaded content
try await downloadContentManager.deleteOfflineData()

// Renew DRM license for downloaded content
try await downloadContentManager.renewOfflineLicense()
```

## API Documentation

For detailed API documentation and advanced features, visit:
[BV API Documentation](https://developers.blendvision.com/_/sdk/player/ios/documentation/bvplayer)
