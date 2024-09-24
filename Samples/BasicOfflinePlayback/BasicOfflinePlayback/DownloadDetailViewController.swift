//
//  DownloadDetailViewController.swift
//  KKSPlayerSample
//
//  Created by Tsung Cheng Lo on 2023/11/15.
//

import UIKit
import BVPlayer
import BVUIControls

class DownloadDetailViewController: UIViewController {
    
    var sourceConfig: UniSourceConfig? {
        didSet {
            guard let sourceConfig = sourceConfig else { return }
            itemNameLabel.text = sourceConfig.title
            itemStatusLabel.text = "NotDownload"
        }
    }
    
    var trackSelection: DownloadTrackSelection?
    
    var downloadConfig = DownloadConfig()
    
    let itemNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24.0)
        return label
    }()
    
    let itemStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20.0)
        return label
    }()
    
    let itemPercentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16.0)
        return label
    }()
    
    let downloadButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Download", for: .normal)
        button.isHidden = true
        return button
    }()
    
    let pauseButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Pause", for: .normal)
        button.isHidden = true
        return button
    }()
    
    let resumeButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Resume", for: .normal)
        button.isHidden = true
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Delete", for: .normal)
        button.isHidden = true
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.isHidden = true
        return button
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Play", for: .normal)
        button.isHidden = true
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [itemNameLabel,
                                                   itemStatusLabel,
                                                   itemPercentageLabel,
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
    
    var downloadContentManager: DownloadContentManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Download Detail"
        view.backgroundColor = .black
        view.addSubview(stackView)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(didCloseButton(_:)))]
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        downloadButton.addTarget(self, action: #selector(didTapDownloadButton(_:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(didTapPauseButton(_:)), for: .touchUpInside)
        resumeButton.addTarget(self, action: #selector(didTapResumeButton(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapPlayButton(_:)), for: .touchUpInside)
        
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
    }
    
    deinit {
        debugPrint("This view controller has been deallocated =\(self)")
    }
    
    @objc func didCloseButton(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    func dismiss() {
        release()
        dismiss(animated: true)
    }
    
    @objc
    func didTapDownloadButton(_ sender: UIButton) {
        guard let tracks = trackSelection else { return }
        downloadConfig.minimumBitrate = 825_000
        downloadContentManager?.download(tracks: tracks, config: downloadConfig)
        setViewState(.downloading)
    }
    
    @objc
    func didTapPauseButton(_ sender: UIButton) {
        downloadContentManager?.suspendDownload()
    }
    
    @objc
    func didTapResumeButton(_ sender: UIButton) {
        downloadContentManager?.resumeDownload()
    }
    
    @objc
    func didTapCancelButton(_ sender: UIButton) {
        cancelDownload()
    }
    
    @objc
    func didTapDeleteButton(_ sender: UIButton) {
        dismiss(animated: true) {
            self.release()
            
            Task {
                do {
                    try await self.downloadContentManager?.deleteOfflineData()
                } catch {
                    debugPrint("error=\(error)")
                }
            }
        }
    }
    
    @objc
    func didTapPlayButton(_ sender: UIButton) {
        guard let offlineSourceConfig = downloadContentManager?.createOfflineSourceConfig() else {
            return
        }
        
        let playerConfig = UniPlayerConfig()
        playerConfig.serviceConfig.version = .v2
        playerConfig.licenseKey = "Your-License-Key"
        
        let player = UniPlayerFactory.create(player: playerConfig)
        let controller = UniPlayerViewController()
        controller.sourceConfig = offlineSourceConfig
        controller.player = player
        
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true) {
            controller.load()
        }
    }
    
    func release() {
        downloadContentManager?.remove(listener: self)
    }
    
    func cancelDownload() {
        downloadContentManager?.cancelDownload()
    }
    
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
        default:
            break
        }
    }
}

extension  DownloadDetailViewController: DownloadContentManagerListener {
    
    func onContentDownloadProgressChanged(_ event: ContentDownloadProgressChangedEvent,
                                          manager: DownloadContentManager) {
        setViewState(.downloading, with: event.progress)
    }
    
    func onContentDownloadFinished(_ event: ContentDownloadFinishedEvent, 
                                   manager: DownloadContentManager) {
        DispatchQueue.main.async {
            self.setViewState(.downloaded)
        }
    }
    
    func onContentDownloadSuspended(_ event: ContentDownloadSuspendedEvent, 
                                    manager: DownloadContentManager) {
        setViewState(.suspended)
    }
    
    func onContentDownloadResumed(_ event: ContentDownloadResumedEvent, 
                                  manager: DownloadContentManager) {
        setViewState(.downloading, with: event.progress)
    }
    
    func onContentDownloadCanceled(_ event: ContentDownloadCanceledEvent, 
                                   manager: DownloadContentManager) {
        setViewState(.canceling)
    }
    
    func onDownloadError(_ event: ContentDownloadErrorEvent, manager: DownloadContentManager) {
        cancelDownload()
        print("Download error=\(event.message)")
    }
}
