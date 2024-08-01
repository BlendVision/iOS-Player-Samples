//
//  AppDelegate.swift
//  BasicCasting
//
//  Created by Tsung Cheng Lo on 2023/9/27.
//

import UIKit
import BVPlayer
import BVUIControls

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize ChromeCast support for this application
        CastManager.initializeCasting()
        
        // Initialize logging
        GCKLogger.sharedInstance().delegate = self
        
        return true
    }
}

extension AppDelegate: GCKLoggerDelegate {
    public func log(fromFunction function: UnsafePointer<Int8>, message: String) {
        print("ChromeCast Log: \(function) \(message)")
    }
}
