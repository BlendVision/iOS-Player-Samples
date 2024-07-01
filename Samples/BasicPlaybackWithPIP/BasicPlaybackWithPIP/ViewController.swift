//
//  ViewController.swift
//  BasicPlaybackWithPIP
//
//  Created by Sunny Cheng on 2024/6/28.
//

import UIKit
import BVPlayer
import AVFoundation

/// To use Picture in Picture (PIP) on iOS, the app needs to be configured in two ways, and users need to enable PIP in their settings.
/// 1. Add Background Modes and check "Audio, Airplay, and Picture in Picture"
/// 2. Set up AVAudioSession
///
/// More information can be found here: https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback
class ViewController: UIViewController {
    var player: UniPlayer!
    
    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        // Define needed resources
        guard let streamUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/70d2984e-0327-4da9-bb81-9e35f8b7c8a1/vod/hls.m3u8")else {
            return
        }
        
        // Create player configuration
        let playerConfig = UniPlayerConfig()
        playerConfig.key = "8895d63a-b150-46d3-bcdb-8c164f9ceb57"
        
        // Create player based on player config
        player = UniPlayerFactory.create(player: playerConfig)
        
        // Create player view config and enable PIP feature
        var playerViewConfig = PlayerViewConfig()
        playerViewConfig.pictureInPictureConfig.isEnabled = true
        
        // Set up AVAudioSession for PIP
        setUpAVAudioSession()
       
        // Create player view and pass the player instance to it
        let playerView = UniPlayerView(player: player, frame: .zero, playerViewConfig: playerViewConfig)
        
        // Listen to player events
        player.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        
        // Listen to playerView events
        playerView.add(listener: self)
        
        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)
        
        // Create source config
        let sourceConfig = UniSourceConfig(url: streamUrl, type: .hls)
        player.load(sourceConfig: sourceConfig)
    }
    
    private func setUpAVAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
}

extension ViewController: UniPlayerListener {
    
    func player(_ player: UniPlayer, didReceiveOnEvent event: UniEvent) {
        // Uncomment the following line to observe the event of player
        // debugPrint("event=\(event)")
    }
}

extension ViewController: UniUserInterfaceListener {
    
    func playerView(_ view: UniPlayerView, didReceiveSettingPressed event: UniUIEvent) {
        if #available(iOS 15.0, *) {
            let navController = UniSheetPresentationController(
                rootViewController: UniSettingViewController(player: player)
            )
            present(navController, animated: true)
        } else {
            // Fallback on earlier versions
            let navController = UINavigationController(
                rootViewController: UniSettingViewController(player: player)
            )
            present(navController, animated: true)
        }
    }
}


