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
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		guard Connectivity.isConnectedToInternet else {
			print("No internet connection")
			return true
		}
		
		// Fetches all image urls ahead of time
		print("Starting background task to fetch image urls")
		var imageUrls: [URL] = []
		let catBreeds = CatBreeds.breeds
		for breed in catBreeds {
			if let breedId = CatBreeds.breedIds[breed] {
				
				CatApi.getCatPhoto(breedId)
				.done { url in
					guard let url = URL(string: url) else { return }
					CatBreeds.imageUrls[breed] = url
					imageUrls.append(url)
					if imageUrls.count == catBreeds.count {
						ImagePrefetcher(urls: imageUrls).start()
						print("All images cached in background")
					}
				  }.catch { error in
						print("Error: \(error)")
				  }
			}
		}
		
		return true
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		if CommandLine.arguments.contains("--uitesting") {
			clearCoreData()
		}
		
		// Status bar appears after splash screen
		UIApplication.shared.isStatusBarHidden = false
		
		return true
	}
	
	func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		return false
	}
	
	func clearCoreData() {
		let context = persistentContainer.viewContext
		let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Cat")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
        } catch {
            print ("There was an error clearing core data")
        }
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		let cache = ImageCache.default
		cache.clearDiskCache { print("Cleared photos is disk cache") }
		cache.clearMemoryCache()
		self.saveContext()
		print("DYING")
	}

	// MARK: - Core Data stack
	lazy var persistentContainer: NSPersistentContainer = {
	  // The persistent container for the application. This implementation
	  // creates and returns a container, having loaded the store for the
	  // application to it. This property is optional since there are legitimate
	  // error conditions that could cause the creation of the store to fail.
	  let container = NSPersistentContainer(name: "CatId")
	  container.loadPersistentStores(completionHandler: { (storeDescription, error) in
		if let error = error as NSError? {
		  /*
		   Typical reasons for an error here include:
		   * The parent directory does not exist, cannot be created, or disallows writing.
		   * The persistent store is not accessible, due to permissions or data protection when the device is locked.
		   * The device is out of space.
		   * The store could not be migrated to the current model version.
		   Check the error message to determine what the actual problem was.
		   */
		  print("Unresolved error \(error), \(error.userInfo)")
		}
	  })
	  return container
	}()

	// MARK: - Core Data Saving support
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				print("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
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

