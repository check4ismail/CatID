//
//  AppDelegate.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/26/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON
import Kingfisher
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		guard Connectivity.isConnectedToInternet else {
			print("No internet connection")
			return true
		}
	
		return true
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		// Override point for customization after application launch.
		if CommandLine.arguments.contains("--uitesting") {
			CoreDataManager.sharedManager.flushDataCat()
			CoreDataManager.sharedManager.flushDataMyCat()
		}
		// Status bar appears after splash screen
		UIApplication.shared.isStatusBarHidden = false
		
		return true
	}
	
	func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		return false
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		let cache = ImageCache.default
		cache.clearDiskCache { print("Cleared photos is disk cache") }
		cache.clearMemoryCache()
		CoreDataManager.sharedManager.saveContext()
		print("DYING")
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

}

