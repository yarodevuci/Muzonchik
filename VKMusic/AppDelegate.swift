//
//  AppDelegate.swift
//  VKMusicTest
//
//  Created by Yaroslav Dukal on 9/15/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import UIKit
import SwiftyDropbox
import CoreData
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DropboxClientsManager.setupWithAppKey(DROPBOX_APP_KEY)
        print(DocumentsDirectory.localDocumentsURL)
		UINavigationBar.appearance().shadowImage = UIImage()
		registerOneSignalNotifications(launchOptions: launchOptions)
        return true
    }
	
	func registerOneSignalNotifications(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		OneSignal.initWithLaunchOptions(launchOptions, appId: ONE_SIGNAL_APP_ID, handleNotificationReceived: { (notification) in
			
			if notification?.payload.additionalData != nil {
			}
		}, handleNotificationAction: { (result) in
			// This block gets called when the user reacts to a notification received (from lock screen)
			
		}, settings: [kOSSettingsKeyInAppAlerts: OSNotificationDisplayType.none.rawValue, kOSSettingsKeyAutoPrompt : true, kOSSettingsKeyInFocusDisplayOption: OSNotificationDisplayType.none.rawValue])
	}
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		CoreDataManager.shared.saveContext()
    }
}

