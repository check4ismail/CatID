//
//  CoreDataManager.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/24/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
	//1
	static let sharedManager = CoreDataManager()
	private init() {} // Prevent clients from creating another instance.
	
	//2
	lazy var persistentContainer: NSPersistentContainer = {
	  
	  let container = NSPersistentContainer(name: "CatId")
	  
	  
	  container.loadPersistentStores(completionHandler: { (storeDescription, error) in
		
		if let error = error as NSError? {
		  print("Unresolved error \(error), \(error.userInfo)")
		}
	  })
	  return container
	}()
	
	//3
	func saveContext () {
	  let context = CoreDataManager.sharedManager.persistentContainer.viewContext
	  if context.hasChanges {
		do {
		  try context.save()
		} catch {
		  // Replace this implementation with code to handle the error appropriately.
		  // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		  let nserror = error as NSError
		  print("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	  }
	}
	
	func flushDataCat() {
		flushData(entityName: "Cat")
	}
	
	func flushDataMyCat() {
		flushData(entityName: "MyCat")
	}
	
	func insertMyCat() {
		let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
		let myCat = MyCat(context: managedContext)
		myCat.setValue(MyCatData.myCat?.name, forKey: "name")
		myCat.setValue(MyCatData.myCat?.breedType, forKey: "breedType")
		myCat.setValue(MyCatData.myCat?.birthdayMonth, forKey: "birthdayMonth")
		myCat.setValue(MyCatData.myCat?.birthdayDay, forKey: "birthdayDay")
		myCat.setValue(MyCatData.myCat?.birthdayYear, forKey: "birthdayYear")
		myCat.setValue(MyCatData.myCat?.notes, forKey: "notes")
		myCat.setValue(MyCatData.myCat?.vetInfo, forKey: "vetInfo")
		myCat.setValue(MyCatData.myCat?.catPhoto, forKey: "catPhoto")
		
		do {
			print("Tried to save myCat data.....")
			try managedContext.save()
			print("Saved myCat DATA!!")
			MyCatData.clearMyCat()
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
	
	func updateMyCat() {
		let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
//		let myCat = MyCatData.myCat
		
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Could not save due to \(error), \(error.userInfo)")
		}
	}
	
	func insertCatDetailedData() {
		let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
		let cat = Cat(context: managedContext)
		cat.setValue(CatDetailedData.data.breed, forKeyPath: "breed")
		cat.setValue(CatDetailedData.data.imageUrl, forKeyPath: "imageUrl")
		cat.setValue(CatDetailedData.data.childFriendlyRating, forKeyPath: "childFriendlyRating")
		cat.setValue(CatDetailedData.data.groomingRating, forKeyPath: "groomingRating")
		cat.setValue(CatDetailedData.data.intelligenceRating, forKeyPath: "intelligenceRating")
		cat.setValue(CatDetailedData.data.sheddingRating, forKeyPath: "sheddingRating")
		cat.setValue(CatDetailedData.data.socialNeedsRating, forKeyPath: "socialNeedsRating")
		cat.setValue(CatDetailedData.data.summaryText, forKeyPath: "summaryText")
		cat.setValue(CatDetailedData.data.temperament, forKeyPath: "temperament")
		cat.setValue(CatDetailedData.data.wikiLink, forKeyPath: "wikiLink")
		
		do {
			print("Tried to save cat data.....")
			try managedContext.save()
			print("Saved cat DATA!!")
			CatDetailedData.data.clearData()
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
		
	}
	
	private func flushData(entityName: String) {
	  
	  let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
	  let objs = try! CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(fetchRequest)
	  for case let obj as NSManagedObject in objs {
		CoreDataManager.sharedManager.persistentContainer.viewContext.delete(obj)
	  }
	  
	  try! CoreDataManager.sharedManager.persistentContainer.viewContext.save()
	}
	
	func fetchAllCatDetails() -> [Cat]?{
	  
	  /*Before you can do anything with Core Data, you need a managed object context. */
	  let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
	  
	  /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
	   
	   Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
	   */
	  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cat")
	  
	  /*You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.*/
	  do {
		let cat = try managedContext.fetch(fetchRequest)
		return cat as? [Cat]
	  } catch let error as NSError {
		print("Could not fetch. \(error), \(error.userInfo)")
		return nil
	  }
	}
	
	func fetchAllMyCats() -> [MyCat]?{
	  
	  /*Before you can do anything with Core Data, you need a managed object context. */
	  let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
	  
	  /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
	   
	   Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
	   */
	  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyCat")
	  
	  /*You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.*/
	  do {
		let myCat = try managedContext.fetch(fetchRequest)
		return myCat as? [MyCat]
	  } catch let error as NSError {
		print("Could not fetch. \(error), \(error.userInfo)")
		return nil
	  }
	}
	
	lazy var fetchedResultsControllerCatDetails: NSFetchedResultsController<Cat> = {
	   
	   /*Before you can do anything with Core Data, you need a managed object context. */
	   let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
	   
	   /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
		
		Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
		*/
	   let fetchRequest = NSFetchRequest<Cat>(entityName: "Cat")
	   
//	   // Add Sort Descriptors
	   let sortDescriptor = NSSortDescriptor(key: "breed", ascending: true)
	   fetchRequest.sortDescriptors = [sortDescriptor]
	   
	   // Initialize Fetched Results Controller
	   let fetchedResultsController = NSFetchedResultsController<Cat>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
	   
	   print("1. NSFetchResultController Initialized :)")
	   return fetchedResultsController
	 }()
	
	lazy var fetchedResultsControllerMyCat: NSFetchedResultsController<MyCat> = {
		   
		   /*Before you can do anything with Core Data, you need a managed object context. */
		   let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
		   
		   /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
			
			Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
			*/
		   let fetchRequest = NSFetchRequest<MyCat>(entityName: "MyCat")
		   
	//	   // Add Sort Descriptors
		   let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		   fetchRequest.sortDescriptors = [sortDescriptor]
		   
		   // Initialize Fetched Results Controller
		   let fetchedResultsController = NSFetchedResultsController<MyCat>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
		   
		   print("1. NSFetchResultController Initialized :)")
		   return fetchedResultsController
		 }()
}
