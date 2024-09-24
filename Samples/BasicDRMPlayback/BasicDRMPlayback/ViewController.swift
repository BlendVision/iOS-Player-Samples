//
//  ViewController.swift
//  BasicDRMPlayback
//
//  Created by Tsung Cheng Lo on 2023/10/20.
//

import UIKit
import BVPlayer
import BVUIControls

class ViewController: UIViewController {
    
    var player: UniPlayer!
    
    deinit {
        player?.destroy()
    }
    
    var certHeader: [String: String] {
        ["x-custom-data": "token_type=upfront&token_value=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNvdXJjZV9pZCI6IjQ5YTVhNzc4LTgwYTAtNDY1OC05ZDU2LTcxNTJmMzRjOWY1ZSIsInJlc291cmNlX3R5cGUiOiJSRVNPVVJDRV9UWVBFX1ZPRCIsImN1c3RvbWVyX2lkIjoiY3VzdG9tZXItaWQiLCJ0ZW5hbnRfaWQiOiI3ZDFlNmQ1ZS02MjQ1LTQzYTMtYWJhMC04ZTE2Y2YzNTNkYjUiLCJvcmdfaWQiOiIxYzE1ZDQyZS1mZTlhLTQ2ZTAtYTAxMy0wMGY2MzFjNTdhZmEiLCJkcm1fY29uZmlnIjp7InZlcnNpb24iOjIsImZhaXJwbGF5Ijp7ImhkY3AiOiJoZGNwX25vbmUiLCJvbmxpbmVfZHVyYXRpb24iOjg2NDAwLCJhbGxvd19hbmFsb2dfb3V0Ijp0cnVlfSwicGxheXJlYWR5Ijp7ImhkY3AiOiJoZGNwX25vbmUiLCJvbmxpbmVfZHVyYXRpb24iOjg2NDAwLCJhbGxvd19hbmFsb2dfb3V0Ijp0cnVlLCJyZXF1aXJlZF9wcl9zZWN1cml0eV9sZXZlbCI6MjAwMH0sIndpZGV2aW5lIjp7ImhkY3AiOiJoZGNwX25vbmUiLCJvbmxpbmVfZHVyYXRpb24iOjg2NDAwLCJhbGxvd19hbmFsb2dfb3V0Ijp0cnVlLCJyZXF1aXJlZF9lbWVfc2VjdXJpdHlfbGV2ZWwiOjF9fSwiaXNzIjoib3JiaXQiLCJzdWIiOiJjdXN0b21lci1pZCIsImlhdCI6MTY4MTM2NDkwOSwianRpIjoiNGMxZjQ3OTgtYWI1Yy00NjRhLWJmZjEtODg5Yjk3OGNkNzU0In0.Z5r3GtUFtRaVqJss4rgVbMEGUjCvY1hDkLDAhfFMmxf3yJajGKEczDZ8kZPFMd0PpXTIsLCnjMg9frOaa9EoYO4e2UpX4_y2RL4YaJBAnauGuVQo5E0vbDCxdHOPWq5nYAmjgSOz5q3cgXB9QJsmvdpQiVRcCUFS7YyDFsuMH61XOIv6zvwQajxuyNni4w7Bk6PsLy9OQ97XFJefM8V7z0jjE0cwMyc5xDvUF1N-_jiGRGHITLrZ_zOdNXyVeh8VVcvSCbIa__aXjImJmB4AHmwOBta2blabAm8OYopY7Mj9QDzpzIHko3Moek1UAPL3sbzqQAfSFafqym4QID_NvQ"]
    }
    
    var licenseHeader: [String: String] {
        ["x-custom-data": "token_type=upfront&token_value=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNvdXJjZV9pZCI6IjQ5YTVhNzc4LTgwYTAtNDY1OC05ZDU2LTcxNTJmMzRjOWY1ZSIsInJlc291cmNlX3R5cGUiOiJSRVNPVVJDRV9UWVBFX1ZPRCIsImN1c3RvbWVyX2lkIjoiY3VzdG9tZXItaWQiLCJ0ZW5hbnRfaWQiOiI3ZDFlNmQ1ZS02MjQ1LTQzYTMtYWJhMC04ZTE2Y2YzNTNkYjUiLCJvcmdfaWQiOiIxYzE1ZDQyZS1mZTlhLTQ2ZTAtYTAxMy0wMGY2MzFjNTdhZmEiLCJkcm1fY29uZmlnIjp7InZlcnNpb24iOjIsImZhaXJwbGF5Ijp7ImhkY3AiOiJoZGNwX25vbmUiLCJvbmxpbmVfZHVyYXRpb24iOjg2NDAwLCJhbGxvd19hbmFsb2dfb3V0Ijp0cnVlfSwicGxheXJlYWR5Ijp7ImhkY3AiOiJoZGNwX25vbmUiLCJvbmxpbmVfZHVyYXRpb24iOjg2NDAwLCJhbGxvd19hbmFsb2dfb3V0Ijp0cnVlLCJyZXF1aXJlZF9wcl9zZWN1cml0eV9sZXZlbCI6MjAwMH0sIndpZGV2aW5lIjp7ImhkY3AiOiJoZGNwX25vbmUiLCJvbmxpbmVfZHVyYXRpb24iOjg2NDAwLCJhbGxvd19hbmFsb2dfb3V0Ijp0cnVlLCJyZXF1aXJlZF9lbWVfc2VjdXJpdHlfbGV2ZWwiOjF9fSwiaXNzIjoib3JiaXQiLCJzdWIiOiJjdXN0b21lci1pZCIsImlhdCI6MTY4MTM2NDkwOSwianRpIjoiNGMxZjQ3OTgtYWI1Yy00NjRhLWJmZjEtODg5Yjk3OGNkNzU0In0.Z5r3GtUFtRaVqJss4rgVbMEGUjCvY1hDkLDAhfFMmxf3yJajGKEczDZ8kZPFMd0PpXTIsLCnjMg9frOaa9EoYO4e2UpX4_y2RL4YaJBAnauGuVQo5E0vbDCxdHOPWq5nYAmjgSOz5q3cgXB9QJsmvdpQiVRcCUFS7YyDFsuMH61XOIv6zvwQajxuyNni4w7Bk6PsLy9OQ97XFJefM8V7z0jjE0cwMyc5xDvUF1N-_jiGRGHITLrZ_zOdNXyVeh8VVcvSCbIa__aXjImJmB4AHmwOBta2blabAm8OYopY7Mj9QDzpzIHko3Moek1UAPL3sbzqQAfSFafqym4QID_NvQ",
         "Content-Type": "application/json"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Define needed resources
        guard let fairplayStreamUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/2e18c688-f643-465f-aa7c-44bc8f2f56b6/vod/hls.m3u8"),
              let certificateUrl = URL(string: "https://drm.platform-qa.kkstream.io/api/v3/drm/license/fairplay_cert"),
              let licenseUrl = URL(string: "https://drm.platform-qa.kkstream.io/api/v3/drm/license") else {
            fatalError("Invalid URL(s) when setting up DRM playback sample")
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
        let sourceConfig = UniSourceConfig(url: fairplayStreamUrl, type: .hls)
        
        // Create drm configuration
        let fpsConfig = UniFairPlayConfig(licenseUrl: licenseUrl, certificateUrl: certificateUrl)
        fpsConfig.certificateRequestHeaders = certHeader
        fpsConfig.licenseRequestHeaders = licenseHeader
        sourceConfig.drmConfig = fpsConfig
        
        // Example of how message request data can be prepared if custom modifications are needed
//        fpsConfig.prepareMessage = { spcData, assetId in
//            spcData
//        }
        
        // Example of how certificate data can be prepared if custom modifications are needed
//        fpsConfig.prepareCertificate = { (data: Data) -> Data in
//            // Do something with the loaded certificate
//            data
//        }
        
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
