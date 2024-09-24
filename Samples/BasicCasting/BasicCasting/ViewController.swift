//
//  ViewController.swift
//  BasicCasting
//
//  Created by Tsung Cheng Lo on 2023/9/27.
//

import UIKit
import BVPlayer
import BVUIControls

struct WidevineMaker {

    func makeWidevineConfig(_ sourceConfig: UniSourceConfig) -> UniSourceConfig? {
        let dashUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/d65451ac-f080-42c7-b3e2-746c4ca40fa7/vod/dash.mpd")!

        // Create DASHSource as a DASH stream is used for casting
        let castSourceConfig = UniSourceConfig(url: dashUrl, type: .dash)
        castSourceConfig.title = sourceConfig.title
        castSourceConfig.sourceDescription = sourceConfig.sourceDescription
        castSourceConfig.castOptions = sourceConfig.castOptions

        return castSourceConfig
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
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")else {
            return
        }
        
        // Create player configuration
        let playerConfig = UniPlayerConfig()
        playerConfig.serviceConfig.version = .v2
        playerConfig.licenseKey = "Your-License-Key"
        
        playerConfig.remoteControlConfig.prepareSource = { type, sourceConfig in
            switch type {
            case .cast:
                // Create a different source for casting
                return WidevineMaker().makeWidevineConfig(sourceConfig)
            @unknown default:
                return nil
            }
        }
        
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
