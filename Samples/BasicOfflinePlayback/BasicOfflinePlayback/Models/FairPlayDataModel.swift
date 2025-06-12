//
//  FairPlayDataModel.swift
//  BasicOfflinePlayback
//
//  Created by Tsung Cheng Lo on 2025/6/12.
//

import Foundation

struct FairPlayDataModel {
    var licenseUrl: String {
        "Your-License-URL"
    }
    
    var fairplayCertUrl: String {
        "Your-FairPlay-Certificate-URL"
    }
    
    var certHeaders: [String: String] {
        // Put your fairPlay certificate headers
        [:]
    }
    
    var licenseHeaders: [String: String] {
        // Put your license headers
        [:]
    }
}
