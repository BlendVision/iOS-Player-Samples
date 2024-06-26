//
//  ViewController.swift
//  BasicPlaybackWithThumbnailSeeking
//
//  Created by Tsung Cheng Lo on 2023/10/20.
//

import UIKit
import BVPlayer

class ViewController: UIViewController {
    
    var player: UniPlayer!
    
    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .black
        
        // Define needed resources
        guard let streamUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/d65451ac-f080-42c7-b3e2-746c4ca40fa7/vod/hls.m3u8") else {
            return
        }
        
        guard let thumbnailUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/d65451ac-f080-42c7-b3e2-746c4ca40fa7/thumbnail/00/thumbnails.vtt") else {
            return
        }
        
        // Create player configuration
        let playerConfig = UniPlayerConfig()
        playerConfig.key = "your-license-key"
        
        // Create player based on player config
        player = UniPlayerFactory.create(player: playerConfig)
        
        // Create player view and pass the player instance to it
        let playerView = UniPlayerView(player: player, frame: .zero)
        
        // Listen to player events
        player.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        
        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)
        
        // Create source config
        let sourceConfig = UniSourceConfig(url: streamUrl, type: .hls)
        
        /// Creates a new thumbnail track based on the given URL and provided metadata.
        sourceConfig.thumbnailTrack = UniThumbnailTrack(
            url: thumbnailUrl,
            label: "thumbnail",
            identifier: UUID().uuidString,
            isDefaultTrack: false
        )
        
        player.load(sourceConfig: sourceConfig)
    }

}

extension ViewController: UniPlayerListener {
    
    func player(_ player: UniPlayer, didReceiveOnEvent event: UniEvent) {
        // Uncomment the following line to observe the event of player
        // debugPrint("event=\(event)")
    }
}
