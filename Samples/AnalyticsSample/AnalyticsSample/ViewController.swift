//
//  ViewController.swift
//  BasicPlayback
//
//  Created by Tsung Cheng Lo on 2023/7/12.
//

import UIKit
import KKSPlayer

class ViewController: UIViewController {
    
    var moduleConfig: [String: String] {
        var config = [String: String]()
        config[AnalyticsField.token.rawValue] = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNvdXJjZV9pZCI6Ijg0MGEyOTFiLWVlNDMtNDE4NC04NjJlLWYwZTEzM2IzMGUxYSIsInJlc291cmNlX3R5cGUiOiJSRVNPVVJDRV9UWVBFX1ZPRF9FVkVOVCIsIm9yZ19pZCI6IjdiMGQ2NGM2LTIwZmItNDFjNi05YTJiLTk1ZjM2MzhiNTJiYyIsInRlbmFudF9pZCI6Ijg1YjljZmFkLTM1Y2MtNDQyNC05NjE1LWNlZmI3ZTNlNzZjMiIsImlzcyI6Im9yYml0IiwiaWF0IjoxNjkyMDgzOTc5LCJqdGkiOiJiODM0MDIwYi03ZjRlLTRiNTMtYjI0ZS1lMTQ4Mjk5YWE3OTgifQ.UeNacSaSPvAfMfrJ2h6o5Tu_2l4Zi4NubUAcDlqE1PvdtZz1cQjO7E8NnFDSpMeu2wbA1944iO6niAI6pPb5rN6aAsRW2zwpoPh5z_4ob7M9GABq6350OiG8MUvQsF1zcSRmGMS4T3HlOPdCUnc0RLLEOMmfObYCZ5SX5Xzv63URSrfCVC9IDnSr8IwoCYH_LhBwgzRS93eNxzniQCd-nvZZLErCeyZHTG5EQV9bTb4jvrl1g7zB803tk3SXIgt14XMA2_V44-v9lgMZOnj1EJuvFvox_gRW4XesE6AGbpqvajSCSRZ8QbeZZUSlaVYAqpsNFwpXIOCr7R8M_g2gLQ"
        config[AnalyticsField.sessionId.rawValue] = "session id"
        config[AnalyticsField.resourceId.rawValue] = "source id"
        config[AnalyticsField.resourceType.rawValue] = "resource type"
        config[AnalyticsField.customData.rawValue] = "custom data"
        return config
    }
    
    var player: UniPlayer!
    
    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")else {
            return
        }
        
        // Create player configuration
        let playerConfig = UniPlayerConfig()
        playerConfig.key = "dd6136d6-1155-45f8-9874-60f10abfc438"
        
        // Create player based on player config and module config
        player = UniPlayerFactory.create(player: playerConfig, moduleConfig: moduleConfig)
        
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
        player.load(sourceConfig: sourceConfig)
    }
}

extension ViewController: UniPlayerListener {
    
    func player(_ player: UniPlayer, didReceiveOnEvent event: UniEvent) {
        // Uncomment the following line to observe the event of player
        // debugPrint("event=\(event)")
    }
}
