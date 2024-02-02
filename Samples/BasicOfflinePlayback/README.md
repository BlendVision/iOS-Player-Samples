#  Basic Offline Playback

## Overview
This sample project demonstrates how to download HLS (HTTP Live Streaming) content using Swift. The project includes a download manager (DownloadManager) that handles the download of HLS content for offline viewing.

## Usage
To use the download functionality, follow these steps:

1. Configure the Source: Make sure to set up the source configuration before initiating the download.
```swift
guard let sourceConfig = self.sourceConfig else { return }
```

2. Create a Download Manager: Initialize the download manager (DownloadManager) and add it as a listener to receive download updates.
```swift
if let manager = try? await DownloadManager.shared.downloadContentManager(for: sourceConfig) {
    downloadContentManager = manager
    downloadContentManager?.add(listener: self)
    trackSelection = try? await downloadContentManager?.fetchAvailableTracks()
} else {
    debugPrint("Failed to create offline content manager")
}
```
3. Download Tracks: Handle user interactions to start, pause, resume, cancel, or delete the download.

- Start download:
```swift
guard let tracks = trackSelection else { return }
downloadConfig.minimumBitrate = 825_000
downloadContentManager?.download(tracks: tracks, config: downloadConfig)
```

- Pause download:
```swift
downloadContentManager?.suspendDownload()
```

- Resume download:
```swift
downloadContentManager?.resumeDownload()
```

- Cancel download:
```swift
downloadContentManager?.cancelDownload()
```

- Delete downloaded data:
```swift
try? await downloadContentManager?.deleteOfflineData()
```

## Monitoring Download Event
 The DownloadContentManagerListener protocol, allowing the view controller to respond to various events related to content download.

```swift
func onContentDownloadProgressChanged(_ event: ContentDownloadProgressChangedEvent, manager: DownloadContentManager)
func onContentDownloadFinished(_ event: ContentDownloadFinishedEvent, manager: DownloadContentManager)
func onContentDownloadSuspended(_ event: ContentDownloadSuspendedEvent, manager: DownloadContentManager)
func onContentDownloadResumed(_ event: ContentDownloadResumedEvent, manager: DownloadContentManager)
func onContentDownloadCanceled(_ event: ContentDownloadCanceledEvent, manager: DownloadContentManager)
func onDownloadError(_ event: ContentDownloadErrorEvent, manager: DownloadContentManager)
```

## Offline Playback
### Offline Source Config
Represents a SourceConfig which references already downloaded or currently downloading offline content. It can passed to a Player instance for playback.
```swift
let offlineSourceConfig = downloadContentManager?.createOfflineSourceConfig()
```
