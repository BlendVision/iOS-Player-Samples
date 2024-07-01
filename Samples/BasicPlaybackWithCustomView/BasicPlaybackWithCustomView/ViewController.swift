//
//  ViewController.swift
//  BasicPlaybackWithThumbnailSeeking
//
//  Created by Tsung Cheng Lo on 2023/10/20.
//

import AVKit
import BVPlayer

class CustomView: UIView {
    init(player: UniPlayer, frame: CGRect) {
        super.init(frame: frame)

        // register the AVPlayerLayer of this view to the Player
        player.register(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
}

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
        guard let streamUrl = URL(string: "https://dsv0d25o8wgwv.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/b416224e-1d90-41dd-a381-f31b2e4db16d/vod/hls.m3u8") else {
            return
        }
        
        // Create player configuration
        let playerConfig = UniPlayerConfig()
        playerConfig.key = "your-license-key"
        
        // Create player based on player config
        player = UniPlayerFactory.create(player: playerConfig)
        
        // Create player view and pass the player instance to it
        let playerView = CustomView(player: player, frame: .zero)
        
        // Listen to player events
        player.add(listener: self)
        
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        
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
    
    func player(_ player: UniPlayer, didReceiveOnReadyEvent event: UniEvent) {
        // The play() method should be called when receive the OnReadyEvent
        player.play()
    }
}
