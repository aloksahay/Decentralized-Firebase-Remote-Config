//
//  AppDelegate.swift
//  RemoteConfigUsageExample
//
//  Created by Alok Sahay on 13.10.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        RemoteAppConfig.setupSharedInstance(withURL: "https://cyan-genetic-barracuda-339.mypinata.cloud/files/bafkreib7texbtz62bsihxto67fyrh7bf237ij3e6kz65wsytw6eu3dau5m?X-Algorithm=PINATA1&X-Date=1728857932014&X-Expires=5000000&X-Method=GET&X-Signature=193547a3a82bf0e4270f2eb344f0d9026bd5e3b0d76474096e61281d352aa536")
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
        RemoteAppConfig.shared.endSession()
    }
    
}

