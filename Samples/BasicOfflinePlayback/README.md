#  Basic Offline Playback

## Overview
This sample project demonstrates how to download HLS (HTTP Live Streaming) content using Swift with full FairPlay DRM support, network monitoring, and offline playback capabilities. The project includes a comprehensive download manager system that handles both online and offline scenarios.

## Key Features
- **FairPlay DRM Support**: Complete DRM license management and persistence
- **Network Status Monitoring**: Automatic network connectivity detection and handling
- **Offline Playback**: Support for two offline playback modes
- **Data Persistence**: Automatic saving of bookmark data and license data
- **Complete Download Lifecycle Management**: Including pause, resume, cancel, delete operations

## Initial Setup

### 1. Configure FairPlay DRM
```swift
let fairPlayDataModel = FairPlayDataModel()

if let licenseUrl = URL(string: fairPlayDataModel.licenseUrl),
   let certUrl = URL(string: fairPlayDataModel.fairplayCertUrl) {
    
    // Create DRM configuration
    let fpsConfig = UniFairPlayConfig(licenseUrl: licenseUrl, certificateUrl: certUrl)
    fpsConfig.certificateRequestHeaders = fairPlayDataModel.certHeaders
    fpsConfig.licenseRequestHeaders = fairPlayDataModel.licenseHeaders
    
    // Configure license persistence
    fpsConfig.persistLicenseData = { assetId, licenseData in
        UserDefaults.standard.setValue(licenseData, forKey: self.licenseIdentifier ?? "unknown key")
    }
    
    sourceConfig?.drmConfig = fpsConfig
}
```

### 2. Network Status Monitoring
```swift
private let networkMonitor = NetworkMonitor.shared

private func setupNetworkStatusObserver() {
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(networkStatusDidChange(_:)),
        name: NSNotification.Name("NetworkStatusChanged"),
        object: nil
    )
}

@objc private func networkStatusDidChange(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let status = userInfo["status"] as? NetworkStatus else { return }
    
    DispatchQueue.main.async {
        self.handleNetworkStatusChange(status)
    }
}
```

## Download Manager Initialization

### 3. Create Download Manager
```swift
// Check network connectivity status
if networkMonitor.isNetworkAvailable() {
    Task {
        guard let sourceConfig = self.sourceConfig else { return }
        
        if let manager = try? await DownloadManager.shared.downloadContentManager(for: sourceConfig) {
            downloadContentManager = manager
            downloadContentManager?.add(listener: self)
            setViewState(manager.downloadState)
            trackSelection = try? await downloadContentManager?.fetchAvailableTracks()
        } else {
            debugPrint("Failed to create offline content manager")
        }
    }
} else {
    // Check for downloaded content in offline state
    if let key = contentIdentifier, let _ = getBookmarkData(key) {
        setViewState(.downloaded)
    }
}
```

## Download Operations

### 4. Start Download
```swift
@objc func didTapDownloadButton(_ sender: UIButton) {
    // Check network connectivity
    guard networkMonitor.isNetworkAvailable() else {
        showNetworkAlert(message: "No network connection, cannot start download")
        return
    }
    
    guard let tracks = trackSelection else { return }
    downloadConfig.minimumBitrate = 825_000
    downloadContentManager?.download(tracks: tracks, config: downloadConfig)
    setViewState(.downloading)
}
```

### 5. Pause Download
```swift
@objc func didTapPauseButton(_ sender: UIButton) {
    downloadContentManager?.suspendDownload()
}
```

### 6. Resume Download
```swift
@objc func didTapResumeButton(_ sender: UIButton) {
    downloadContentManager?.resumeDownload()
}
```

### 7. Cancel Download
```swift
@objc func didTapCancelButton(_ sender: UIButton) {
    downloadContentManager?.cancelDownload()
}
```

### 8. Delete Downloaded Content
```swift
@objc func didTapDeleteButton(_ sender: UIButton) {
    Task {
        do {
            // Remove license data
            if let identifier = self.licenseIdentifier {
                self.removeLicenseData(forKey: identifier)
            }
            // Remove bookmark data
            if let identifier = self.contentIdentifier {
                self.removeBookmarkData(identifier: identifier)
            }
            
            // Delete offline content files
            try await self.downloadContentManager?.deleteOfflineData()
        } catch {
            debugPrint("error=\(error)")
        }
    }
}
```

## Data Persistence Management

### 9. Bookmark Data Management
```swift
// Save bookmark data
func setBookmarkData(_ data: Data?, forKey key: String) {
    UserDefaults.standard.setValue(data, forKey: key)
}

// Retrieve bookmark data
func getBookmarkData(_ key: String) -> Data? {
    UserDefaults.standard.value(forKey: key) as? Data
}

// Create URL from bookmark data
func getLocalFileUrl(identifier: String) -> URL? {
    var bookmarkDataIsStale = false
    
    guard let bookmarkData = getBookmarkData(identifier),
          let localFileUrl = try? URL(resolvingBookmarkData: bookmarkData,
                                      bookmarkDataIsStale: &bookmarkDataIsStale) else {
        debugPrint("Failed to create URL from bookmark!")
        return nil
    }
    return localFileUrl
}
```

### 10. License Data Management
```swift
// Save FairPlay license data
func setLicenseData(_ data: Data, forKey key: String) {
    UserDefaults.standard.setValue(data, forKey: key)
}

// Retrieve FairPlay license data
func getLicenseData(forKey key: String) -> Data? {
    UserDefaults.standard.value(forKey: key) as? Data
}
```

## Offline Playback

### 11. Online Mode Playback (Using OfflineSourceConfig)
```swift
func playOfflineSourceConfig() {
    guard let offlineSourceConfig = downloadContentManager?.createOfflineSourceConfig() else {
        return
    }
    play(offlineSourceConfig)
}
```

### 12. Offline Mode Playback (Using MOV Package)
```swift
func playMOVPackage() {
    guard let identifier = contentIdentifier, 
          let localFileURL = getLocalFileUrl(identifier: identifier) else {
        debugPrint("No local file found")
        return
    }
    
    let movpkgSourceConfig = UniSourceConfig(url: localFileURL, type: .movpkg)
    
    // Configure license provider for offline playback
    currentFairPlayConfig?.provideLicenseData = { assetId -> Data? in
        guard let identifier = self.licenseIdentifier else { return nil }
        return self.getLicenseData(forKey: identifier)
    }
    
    movpkgSourceConfig.drmConfig = currentFairPlayConfig
    play(movpkgSourceConfig)
}
```

## Download Event Monitoring

### 13. Implement DownloadContentManagerListener
```swift
extension DownloadDetailViewController: DownloadContentManagerListener {
    
    // Download progress update
    func onContentDownloadProgressChanged(_ event: ContentDownloadProgressChangedEvent,
                                          manager: DownloadContentManager) {
        setViewState(.downloading, with: event.progress)
    }
    
    // Download completion - save bookmark data
    func onContentDownloadFinished(_ event: ContentDownloadFinishedEvent,
                                   manager: DownloadContentManager) {
        if let bookmarkData = (event as? DefaultContentDownloadFinishedEvent)?.bookmarkData {
            if let key = self.contentIdentifier {
                setBookmarkData(bookmarkData, forKey: key)
                debugPrint("bookmark data has been saved")
            }
        }
        
        DispatchQueue.main.async {
            self.setViewState(.downloaded)
        }
    }
    
    // Download suspended
    func onContentDownloadSuspended(_ event: ContentDownloadSuspendedEvent, 
                                    manager: DownloadContentManager) {
        setViewState(.suspended)
    }
    
    // Download resumed
    func onContentDownloadResumed(_ event: ContentDownloadResumedEvent, 
                                  manager: DownloadContentManager) {
        setViewState(.downloading, with: event.progress)
    }
    
    // Download canceled
    func onContentDownloadCanceled(_ event: ContentDownloadCanceledEvent, 
                                   manager: DownloadContentManager) {
        setViewState(.canceling)
    }
    
    // Download error handling
    func onDownloadError(_ event: ContentDownloadErrorEvent, 
                         manager: DownloadContentManager) {
        cancelDownload()
        print("Download error=\(event.message)")
    }
}
```

## Network Status Handling

### 14. Network Status Change Handling
```swift
private func handleNetworkStatusChange(_ status: NetworkStatus) {
    updateNetworkStatusLabel(status)
    
    switch status {
    case .connected:
        // Consider auto-resuming paused downloads when network is restored
        if let downloadState = downloadContentManager?.downloadState, 
           downloadState == .suspended {
            showResumeDownloadAlert()
        }
        
    case .disconnected:
        // Pause ongoing downloads when network disconnects
        if let downloadState = downloadContentManager?.downloadState,
           downloadState == .downloading {
            downloadContentManager?.suspendDownload()
            showNetworkAlert(message: "Network connection interrupted, download paused")
        }
        
    case .unknown:
        debugPrint("🌐 Network status unknown")
    }
}
```

## Resource Management

### 15. Release Resources
```swift
func release() {
    downloadContentManager?.remove(listener: self)
}

deinit {
    // Remove network status observer to prevent memory leaks
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NetworkStatusChanged"), object: nil)
}
```
