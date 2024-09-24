//
//  ViewController.swift
//  BasicPlayback
//
//  Created by Tsung Cheng Lo on 2023/7/12.
//

import UIKit
import BVPlayer
import BVUIControls

class ViewController: UIViewController {
    
    var player: UniPlayer!
    
    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        // Define needed resources
        guard let streamUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/87b38a4f-d685-4776-9af7-70cc653d91b9/vod/hls.m3u8")else {
            return
        }
        
        // Create player configuration
        let playerConfig = UniPlayerConfig()
        playerConfig.serviceConfig.version = .v2
        playerConfig.licenseKey = "Your-License-Key"
        
        // Create player based on player config
        player = UniPlayerFactory.create(player: playerConfig)
        
        // Create player view and pass the player instance to it
        let playerView = UniPlayerView(player: player, frame: .zero)
        
        // Listen to player events
        player.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        playerView.add(listener: self)
        
        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)
        
        // Create source config
        let sourceConfig = UniSourceConfig(url: streamUrl, type: .hls)
        player.load(sourceConfig: sourceConfig)
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


