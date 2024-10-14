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
        RemoteAppConfig.setupSharedInstance(withURL: "https://cyan-genetic-barracuda-339.mypinata.cloud/files/bafkreiemhccofg2plvftassurdzsvhufxavw4yu3dbpja75n7yzibzzmja?X-Algorithm=PINATA1&X-Date=1728869727699&X-Expires=7776000&X-Method=GET&X-Signature=014c9890de1d90479c79d10ded03f25002e268494e56256df97459712766a848")
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

