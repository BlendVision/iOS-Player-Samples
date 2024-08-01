//
//  ViewController.swift
//  BasicAudioPlayback
//
//  Created by Tsung Cheng Lo on 2023/7/12.
//

import UIKit
import BVPlayer
import BVUIControls

class ViewController: UIViewController {
    
    var player: UniPlayer!
    
    var playerView: UniPlayerView!
    
    var sourceConfig: UniSourceConfig?
    
    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        // Define needed resources
        guard let streamUrl = URL(string: "https://s3-ap-northeast-1.amazonaws.com/smt-theater/theater/audio_only/bop/sample_1/hls.m3u8")else {
            return
        }
        
        // Create player configuration
        let playerConfig = UniPlayerConfig()
        playerConfig.key = "Your-license-Key"
        playerConfig.playbackConfig.isAutoplayEnabled = false

        // Create player based on player config
        player = UniPlayerFactory.create(player: playerConfig)
        
        // Create player view and pass the player instance to it
        playerView = UniPlayerView(player: player, frame: .zero)
        
        // Listen to player events
        player.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        playerView.add(listener: self)
        
        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)
        
        // Create source config
        sourceConfig = UniSourceConfig(url: streamUrl, type: .hls)
        // Set poster to source config
        sourceConfig?.posterSource = URL(string: "https://august-image.s3.ap-northeast-1.amazonaws.com/Logo_BlendVision_One_Color.png")
        // Set poster to player view config
        playerView.posterViewConfig = PosterViewConfig(source: sourceConfig!)
        
        player.load(sourceConfig: sourceConfig!)
    }
}

extension ViewController: UniPlayerListener {
    
    func player(_ player: UniPlayer, didReceiveOnEvent event: UniEvent) {
        // Uncomment the following line to observe the event of player
        debugPrint("event=\(event)")
    }
    
    func player(_ player: UniPlayer, didReceiveOnPlayingEvent event: UniEvent) {
        playerView.posterViewConfig = nil
        
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
