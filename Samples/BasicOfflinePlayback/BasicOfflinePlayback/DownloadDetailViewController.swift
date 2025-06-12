//
//  DownloadDetailViewController.swift
//  KKSPlayerSample
//
//  Created by Tsung Cheng Lo on 2023/11/15.
//

import UIKit
import BVPlayer
import BVUIControls
import Network

/**
 * DownloadDetailViewController manages the download process for offline playback
 * Handles FairPlay DRM, network monitoring, and download state management
 */
class DownloadDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    /// FairPlay DRM data model for license and certificate management
    let fairPlayDataModel = FairPlayDataModel()
    
    /// Network monitor instance for checking connectivity status
    private let networkMonitor = NetworkMonitor.shared
    
    // MARK: - Bookmark Data Management
    
    /// Save bookmark data to UserDefaults for later access to downloaded content
    func setBookmarkData(_ data: Data?, forKey key: String) {
        UserDefaults.standard.setValue(data, forKey: key)
    }
    
    /// Retrieve bookmark data from UserDefaults
    func getBookmarkData(_ key: String) -> Data? {
        UserDefaults.standard.value(forKey: key) as? Data
    }
    
    /// Remove bookmark data from UserDefaults
    func removeBookmarkData(identifier: String) {
        UserDefaults.standard.removeObject(forKey: identifier)
    }
    
    /// Create URL from bookmark data for accessing downloaded files
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
    
    // MARK: - License Data Management
    
    /// Save FairPlay license data to UserDefaults
    func setLicenseData(_ data: Data, forKey key: String) {
        UserDefaults.standard.setValue(data, forKey: key)
    }
    
    /// Retrieve FairPlay license data from UserDefaults
    func getLicenseData(forKey key: String) -> Data? {
        UserDefaults.standard.value(forKey: key) as? Data
    }
    
    /// Remove FairPlay license data from UserDefaults
    func removeLicenseData(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Configuration Properties
    
    /// Source configuration containing media information and DRM settings
    var sourceConfig: UniSourceConfig? {
        didSet {
            guard let sourceConfig = sourceConfig else { return }
            itemNameLabel.text = sourceConfig.title
            itemStatusLabel.text = "NotDownload"
        }
    }
    
    /// Identifier for storing license data in UserDefaults
    var licenseIdentifier: String? {
        sourceConfig?.title?.appending(".license")
    }
    
    /// Identifier for storing content bookmark data in UserDefaults
    var contentIdentifier: String? {
        self.sourceConfig?.title?.appending(".content")
    }
    
    /// Current FairPlay configuration for DRM protection
    var currentFairPlayConfig: UniFairPlayConfig?
    
    /// Track selection configuration for download quality and languages
    var trackSelection: DownloadTrackSelection?
    
    /// Download configuration settings
    var downloadConfig = DownloadConfig()
    
    // MARK: - UI Elements
    
    /// Label displaying the media item name
    let itemNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24.0)
        return label
    }()
    
    /// Label showing current download status
    let itemStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20.0)
        return label
    }()
    
    /// Label displaying download progress percentage
    let itemPercentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16.0)
        return label
    }()
    
    /// Label showing current network connectivity status
    let networkStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 14.0)
        label.text = "網路狀態: 檢查中..."
        return label
    }()
    
    /// Button to start downloading content
    let downloadButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Download", for: .normal)
        button.isHidden = true
        return button
    }()
    
    /// Button to pause ongoing download
    let pauseButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Pause", for: .normal)
        button.isHidden = true
        return button
    }()
    
    /// Button to resume paused download
    let resumeButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Resume", for: .normal)
        button.isHidden = true
        return button
    }()
    
    /// Button to delete downloaded content
    let deleteButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Delete", for: .normal)
        button.isHidden = true
        return button
    }()
    
    /// Button to cancel ongoing download
    let cancelButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.isHidden = true
        return button
    }()
    
    /// Button to play downloaded content
    let playButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Play", for: .normal)
        button.isHidden = true
        return button
    }()
    
    /// Stack view containing all UI elements in vertical arrangement
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [itemNameLabel,
                                                   itemStatusLabel,
                                                   itemPercentageLabel,
                                                   networkStatusLabel,
                                                   downloadButton,
                                                   pauseButton,
                                                   resumeButton,
                                                   deleteButton,
                                                   cancelButton,
                                                   playButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8.0
        return stack
    }()
    
    /// Manager responsible for handling download operations
    var downloadContentManager: DownloadContentManager?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup basic view properties
        title = "Download Detail"
        view.backgroundColor = .black
        view.addSubview(stackView)
        
        // Setup navigation bar with close button
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(didCloseButton(_:)))]
        
        // Setup Auto Layout constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Setup button actions
        downloadButton.addTarget(self, action: #selector(didTapDownloadButton(_:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(didTapPauseButton(_:)), for: .touchUpInside)
        resumeButton.addTarget(self, action: #selector(didTapResumeButton(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapPlayButton(_:)), for: .touchUpInside)
        
        // Setup network status monitoring
        setupNetworkStatusObserver()
        
        // Configure FairPlay DRM if URLs are available
        if let licenseUrl = URL(string: fairPlayDataModel.licenseUrl),
           let certUrl = URL(string: fairPlayDataModel.fairplayCertUrl) {
            
            // Create DRM configuration with license and certificate URLs
            let fpsConfig = UniFairPlayConfig(licenseUrl: licenseUrl, certificateUrl: certUrl)
            fpsConfig.certificateRequestHeaders = fairPlayDataModel.certHeaders
            fpsConfig.licenseRequestHeaders = fairPlayDataModel.licenseHeaders
            currentFairPlayConfig = fpsConfig
            sourceConfig?.drmConfig = fpsConfig
            
            // Configure license persistence callback
            fpsConfig.persistLicenseData = { assetId, licenseData in
                UserDefaults.standard.setValue(
                    licenseData,
                    forKey: self.licenseIdentifier ?? "unknown key"
                )
            }
        }
        
        if networkMonitor.isNetworkAvailable() {
            // Initialize download content manager asynchronously
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
            if let key = contentIdentifier, let _ = getBookmarkData(key) {
                setViewState(.downloaded)
            }
        }
    }
    
    deinit {
        debugPrint("This view controller has been deallocated =\(self)")
        // Remove network status observer to prevent memory leaks
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NetworkStatusChanged"), object: nil)
    }
    
    // MARK: - Button Actions
    
    /// Handle close button tap - dismisses the view controller
    @objc func didCloseButton(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    /// Dismiss view controller and clean up resources
    func dismiss() {
        release()
        dismiss(animated: true)
    }
    
    /// Handle download button tap - starts download if network is available
    @objc
    func didTapDownloadButton(_ sender: UIButton) {
        // Check network connectivity before starting download
        guard networkMonitor.isNetworkAvailable() else {
            showNetworkAlert(message: "無網路連接，無法開始下載")
            return
        }
        
        guard let tracks = trackSelection else { return }
        downloadConfig.minimumBitrate = 825_000
        downloadContentManager?.download(tracks: tracks, config: downloadConfig)
        setViewState(.downloading)
    }
    
    /// Handle pause button tap - suspends ongoing download
    @objc
    func didTapPauseButton(_ sender: UIButton) {
        downloadContentManager?.suspendDownload()
    }
    
    /// Handle resume button tap - resumes paused download
    @objc
    func didTapResumeButton(_ sender: UIButton) {
        downloadContentManager?.resumeDownload()
    }
    
    /// Handle cancel button tap - cancels ongoing download
    @objc
    func didTapCancelButton(_ sender: UIButton) {
        cancelDownload()
    }
    
    /// Handle delete button tap - removes downloaded content and associated data
    @objc
    func didTapDeleteButton(_ sender: UIButton) {
        dismiss(animated: true) {
            self.release()
            
            Task {
                do {
                    // Remove license data from UserDefaults
                    if let identifier = self.licenseIdentifier {
                        self.removeLicenseData(forKey: identifier)
                    }
                    // Remove bookmark data from UserDefaults
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
    }
    
    /// Handle play button tap - plays downloaded content
    @objc
    func didTapPlayButton(_ sender: UIButton) {
        if networkMonitor.isNetworkAvailable() {
            debugPrint("play with offline source config")
            playOfflineSourceConfig()
        } else {
            debugPrint("play with MOV package")
            playMOVPackage()
        }
    }
    
    func playOfflineSourceConfig() {
        guard let offlineSourceConfig = downloadContentManager?.createOfflineSourceConfig() else {
            return
        }
        
        play(offlineSourceConfig)
    }
    
    // MARK: - Playback Methods
    
    /// Play downloaded MOV package with FairPlay DRM
    func playMOVPackage() {
        guard let identifier = contentIdentifier, let localFileURL = getLocalFileUrl(identifier: identifier) else {
            debugPrint("No local file found")
            return
        }
        let movpkgSourceConfig = UniSourceConfig(url: localFileURL, type: .movpkg)
        
        // Configure license provider for offline playback
        currentFairPlayConfig?.provideLicenseData =  { assetId -> Data? in
            guard let identifier = self.licenseIdentifier else {
                return nil
            }
            return self.getLicenseData(forKey: identifier)
        }
        
        movpkgSourceConfig.drmConfig = currentFairPlayConfig
        play(movpkgSourceConfig)
    }
    
    /// Present player view controller with given source configuration
    func play(_ sourceConfig: UniSourceConfig) {
        let player = UniPlayerFactory.createPlayer(playerConfig: UniPlayerConfig())
        let controller = UniPlayerViewController()
        controller.sourceConfig = sourceConfig
        controller.player = player
        
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true) {
            controller.load()
        }
    }
    
    // MARK: - Resource Management
    
    /// Release download content manager resources
    func release() {
        downloadContentManager?.remove(listener: self)
    }
    
    /// Cancel ongoing download operation
    func cancelDownload() {
        downloadContentManager?.cancelDownload()
    }
    
    /// Update UI based on current download state
    func setViewState(_ state: DownloadState, with progress: Double = 0.0) {
        switch state {
        case .downloaded:
            itemStatusLabel.text = "Downloaded"
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            deleteButton.isHidden = false
            cancelButton.isHidden = true
            playButton.isHidden = false
            itemPercentageLabel.text = ""
        case .downloading:
            downloadButton.isHidden = true
            pauseButton.isHidden = false
            resumeButton.isHidden = true
            cancelButton.isHidden = false
            deleteButton.isHidden = true
            playButton.isHidden = true
            itemStatusLabel.text = "Downloading:"
            itemPercentageLabel.text = String(format: "%.f", progress) + "%"
        case .suspended:
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = false
            cancelButton.isHidden = true
            deleteButton.isHidden = true
            playButton.isHidden = true
            itemStatusLabel.text = "Suspended"
            itemPercentageLabel.text = ""
        case .notDownloaded:
            itemStatusLabel.text = "Not downloaded"
            downloadButton.isHidden = false
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            deleteButton.isHidden = true
            cancelButton.isHidden = true
            playButton.isHidden = true
            itemPercentageLabel.text = ""
        case .canceling:
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = true
            deleteButton.isHidden = true
            playButton.isHidden = true
            itemStatusLabel.text = "Canceling"
            itemPercentageLabel.text = ""
        @unknown default:
            debugPrint("unknown default!!!")
        }
    }
    
    // MARK: - Network Monitoring
    
    /// Setup network status observer for monitoring connectivity changes
    private func setupNetworkStatusObserver() {
        // Listen for network status change notifications from AppDelegate
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusDidChange(_:)),
            name: NSNotification.Name("NetworkStatusChanged"),
            object: nil
        )
        
        // Initialize display with current network status
        updateNetworkStatusLabel(networkMonitor.checkCurrentStatus())
    }
    
    /// Handle network status change notifications
    @objc private func networkStatusDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let status = userInfo["status"] as? NetworkStatus else {
            return
        }
        
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async {
            self.handleNetworkStatusChange(status)
        }
    }
    
    /// Process network status changes and update UI accordingly
    private func handleNetworkStatusChange(_ status: NetworkStatus) {
        updateNetworkStatusLabel(status)
        
        switch status {
        case .connected:
            debugPrint("🌐 網路已連接")
            // Consider auto-resuming paused downloads when network is restored
            if let downloadState = downloadContentManager?.downloadState, 
               downloadState == .suspended {
                // Option to auto-resume download or ask user
                showResumeDownloadAlert()
            }
            
        case .disconnected:
            debugPrint("🌐 網路已斷開")
            // Pause download if currently downloading when network disconnects
            if let downloadState = downloadContentManager?.downloadState,
               downloadState == .downloading {
                downloadContentManager?.suspendDownload()
                showNetworkAlert(message: "網路連接中斷，下載已暫停")
            }
            
        case .unknown:
            debugPrint("🌐 網路狀態未知")
        }
    }
    
    /// Update network status label with current connectivity information
    private func updateNetworkStatusLabel(_ status: NetworkStatus) {
        let connectionType = networkMonitor.getConnectionTypeDescription()
        
        switch status {
        case .connected:
            networkStatusLabel.text = "網路狀態: 已連接 (\(connectionType))"
            networkStatusLabel.textColor = .systemGreen
            
            // Show warning for expensive connections (cellular data)
            if networkMonitor.isExpensiveConnection() {
                networkStatusLabel.text = "網路狀態: 已連接 (\(connectionType)) - 使用行動數據"
                networkStatusLabel.textColor = .systemOrange
            }
            
        case .disconnected:
            networkStatusLabel.text = "網路狀態: 無連接"
            networkStatusLabel.textColor = .systemRed
            
        case .unknown:
            networkStatusLabel.text = "網路狀態: 檢查中..."
            networkStatusLabel.textColor = .systemYellow
        }
    }
    
    /// Show network-related alert messages to user
    private func showNetworkAlert(message: String) {
        let alert = UIAlertController(title: "網路狀態", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    /// Show confirmation dialog for resuming download when network is restored
    private func showResumeDownloadAlert() {
        let alert = UIAlertController(
            title: "網路已恢復", 
            message: "是否要繼續下載？", 
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "繼續下載", style: .default) { _ in
            self.downloadContentManager?.resumeDownload()
        })
        
        alert.addAction(UIAlertAction(title: "稍後手動恢復", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - DownloadContentManagerListener

/// Extension implementing download content manager delegate methods
extension  DownloadDetailViewController: DownloadContentManagerListener {
    
    /// Handle download progress updates
    func onContentDownloadProgressChanged(_ event: ContentDownloadProgressChangedEvent,
                                          manager: DownloadContentManager) {
        setViewState(.downloading, with: event.progress)
    }
    
    /// Handle download completion - save bookmark data for offline access
    func onContentDownloadFinished(_ event: ContentDownloadFinishedEvent,
                                   manager: DownloadContentManager) {
        if let bookmarkData = (event as? DefaultContentDownloadFinishedEvent)?.bookmarkData {
            if let key = self.contentIdentifier {
                setBookmarkData(bookmarkData, forKey: key)
                debugPrint("bookmark data has been saved =\(bookmarkData)")
            }
        }
        
        DispatchQueue.main.async {
            self.setViewState(.downloaded)
        }
    }
    
    /// Handle download suspension
    func onContentDownloadSuspended(_ event: ContentDownloadSuspendedEvent, 
                                    manager: DownloadContentManager) {
        setViewState(.suspended)
    }
    
    /// Handle download resumption
    func onContentDownloadResumed(_ event: ContentDownloadResumedEvent, 
                                  manager: DownloadContentManager) {
        setViewState(.downloading, with: event.progress)
    }
    
    /// Handle download cancellation
    func onContentDownloadCanceled(_ event: ContentDownloadCanceledEvent, 
                                   manager: DownloadContentManager) {
        setViewState(.canceling)
    }
    
    /// Handle download errors - cancel download and log error
    func onDownloadError(_ event: ContentDownloadErrorEvent, manager: DownloadContentManager) {
        cancelDownload()
        print("Download error=\(event.message)")
    }
}
