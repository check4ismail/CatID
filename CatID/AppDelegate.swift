//
//  AppDelegate.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/26/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import PromiseKit
import SwiftyJSON
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
//	private var realm: Realm? = nil
//
//	private func writeToRealm(_ breeds: [Breed]) {
//		print("Writing to realm database....")
//		realm?.beginWrite()
//		for breed in breeds {
//			realm?.add(breed)
//		}
//
//		try! realm?.commitWrite()
//		print("Realm committed writing")
//	}
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
						print(imageUrls)
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
//		do {
//			realm = try Realm()
//			guard realm!.isEmpty else {
//				print("Realm is not empty")
//				return true
//			}
//
//			let catBreeds: [String] = CatBreeds().getBreeds()
//			var arrayOfBreeds: [Breed] = []
//
//			for catBreed in catBreeds {
//				let breed: Breed = Breed()
//				breed.breedName = catBreed
//				arrayOfBreeds.append(breed)
//			}
				
//		print("Getting all image urls for each cat breed")
//		for breed in CatBreeds.breeds {
//			CatApi.getCatPhoto(CatBreeds.breedIds[breed]!)
//			.done{ url in
//				if let url = URL(string: url) {
//					CatBreeds.imageUrls[breed] = url
//				}
//			}.catch { error in
//				print("Error: \(error)")
//			}
//		}
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

}

