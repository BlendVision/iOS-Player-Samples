//
//  AppDelegate.swift
//  BasicOfflinePlayback
//
//  Created by Tsung Cheng Lo on 2024/1/4.
//

import UIKit
import Network

// MARK: - NetworkStatus
enum NetworkStatus {
    case connected
    case disconnected
    case unknown
    
    var isConnected: Bool {
        return self == .connected
    }
}

// MARK: - NetworkMonitorDelegate
protocol NetworkMonitorDelegate: AnyObject {
    func networkMonitor(_ monitor: NetworkMonitor, didChangeStatus status: NetworkStatus)
}

// MARK: - NetworkMonitor
class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .background)
    
    private(set) var currentStatus: NetworkStatus = .unknown
    private(set) var isMonitoring = false
    
    weak var delegate: NetworkMonitorDelegate?
    
    // Using closure callback approach
    var statusChangeHandler: ((NetworkStatus) -> Void)?
    
    private init() {
        setupMonitor()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Start monitoring network status
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        monitor.start(queue: queue)
        isMonitoring = true
        
        debugPrint("🌐 NetworkMonitor: Start monitoring network status")
    }
    
    /// Stop monitoring network status
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        monitor.cancel()
        isMonitoring = false
        
        debugPrint("🌐 NetworkMonitor: Stop monitoring network status")
    }
    
    /// Check current network status
    func checkCurrentStatus() -> NetworkStatus {
        return currentStatus
    }
    
    /// Check if network is available
    func isNetworkAvailable() -> Bool {
        return currentStatus.isConnected
    }
    
    /// Get network connection type description
    func getConnectionTypeDescription() -> String {
        let path = monitor.currentPath
        
        if path.usesInterfaceType(.wifi) {
            return "Wi-Fi"
        } else if path.usesInterfaceType(.cellular) {
            return "Cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            return "Ethernet"
        } else {
            return "Unknown"
        }
    }
    
    /// Check if connection is expensive (e.g. cellular data)
    func isExpensiveConnection() -> Bool {
        return monitor.currentPath.isExpensive
    }
    
    /// Check if connection is constrained
    func isConstrainedConnection() -> Bool {
        return monitor.currentPath.isConstrained
    }
    
    // MARK: - Private Methods
    
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let newStatus = self.determineNetworkStatus(from: path)
            
            // Only trigger callback when status changes
            if newStatus != self.currentStatus {
                let previousStatus = self.currentStatus
                self.currentStatus = newStatus
                
                debugPrint("🌐 NetworkMonitor: Network status changed \(previousStatus) -> \(newStatus)")
                
                // Execute callback on main thread
                DispatchQueue.main.async {
                    self.delegate?.networkMonitor(self, didChangeStatus: newStatus)
                    self.statusChangeHandler?(newStatus)
                }
            }
        }
    }
    
    private func determineNetworkStatus(from path: NWPath) -> NetworkStatus {
        if path.status == .satisfied {
            return .connected
        } else {
            return .disconnected
        }
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Start network monitor
        setupNetworkMonitoring()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        // Stop network monitor
        NetworkMonitor.shared.stopMonitoring()
        debugPrint("🌐 App is about to terminate, stop network monitoring")
    }
    
    // MARK: - Network Monitoring Setup
    
    /// Setup global network monitoring
    private func setupNetworkMonitoring() {
        let networkMonitor = NetworkMonitor.shared
        
        // Setup global network status change handler
        networkMonitor.statusChangeHandler = { status in
            DispatchQueue.main.async {
                self.handleGlobalNetworkStatusChange(status)
            }
        }
        
        // Start monitoring
        networkMonitor.startMonitoring()
        
        debugPrint("🌐 App starts global network monitoring on launch")
        debugPrint("🌐 Initial network status: \(networkMonitor.checkCurrentStatus())")
    }
    
    /// Handle global network status change
    private func handleGlobalNetworkStatusChange(_ status: NetworkStatus) {
        switch status {
        case .connected:
            debugPrint("🌐 [Global] Network connected - \(NetworkMonitor.shared.getConnectionTypeDescription())")
            
            // Log if using expensive connection
            if NetworkMonitor.shared.isExpensiveConnection() {
                debugPrint("⚠️ [Global] Currently using expensive network connection (cellular data)")
            }
            
            // Send global notification to let other View Controllers know about network status change
            NotificationCenter.default.post(
                name: NSNotification.Name("NetworkStatusChanged"),
                object: nil,
                userInfo: ["status": status]
            )
            
        case .disconnected:
            debugPrint("🔴 [Global] Network disconnected")
            
            // Send network disconnection notification
            NotificationCenter.default.post(
                name: NSNotification.Name("NetworkStatusChanged"),
                object: nil,
                userInfo: ["status": status]
            )
            
        case .unknown:
            debugPrint("🟡 [Global] Network status unknown")
        }
    }
}

