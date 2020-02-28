//
//  MyCatController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/22/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import CoreData

protocol ModalHandler {
  func modalDismissed()
}

class MyCatController: UIViewController, UITabBarDelegate, ModalHandler {
	
	@IBOutlet weak var tabBar: UITabBar!
	@IBOutlet weak var myCatTableView: UITableView!
	
	private let segueToBreedList = "catBreedSegue"
	private let segueToAddCat = "addCat"
	private let myCatTag = 0
	
	private let cachePhotos = NSCache<NSString, UIImage>()
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
	}
	
	override func viewDidLoad() {
		fetchAllMyCats()
		tabBar.delegate = self
		highlightTagItem(myCatTag, tabBar)
		
		setupNavigationBar()
		myCatTableView.delegate = self
		myCatTableView.dataSource = self
		myCatTableView.reloadData()
		if myCatTableView.numberOfRows(inSection: 0) == 0 {
			myCatTableView.separatorStyle = .none
		} else {
			myCatTableView.separatorStyle = .singleLine
		}
	}
	
	func modalDismissed() {
		print("Modal dismissed called")
	}
	
	func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		let tabBarItemTag = item.tag
		switch tabBarItemTag {
		case 1:
			performSegue(withIdentifier: segueToBreedList, sender: self)
		case 2:
			print("Working on it")
		default:
			print("Nothing happens because it's the same tag")
		}
	}
	
	@IBAction func addNewCat(_ sender: Any) {
		performSegue(withIdentifier: segueToAddCat, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == segueToAddCat {
			let addCatVC: AddCatController = segue.destination as! AddCatController
			addCatVC.delegate = self
		}
		highlightTagItem(myCatTag, tabBar)
	}
	
	func fetchAllMyCats(){

	  /*This class is delegate of fetchedResultsController protocol methods*/
		CoreDataManager.sharedManager.fetchedResultsControllerMyCat.delegate = self
		do {
			print("2. NSFetchResultController will start fetching :)")
			try CoreDataManager.sharedManager.fetchedResultsControllerMyCat.performFetch()
			print("3. NSFetchResultController did end fetching :)")
		} catch {
			print(error)
		}
	}
}

extension MyCatController: NSFetchedResultsControllerDelegate {
	
	// Automatically called before persisted data changes
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		myCatTableView.beginUpdates()
	}
	
	// Persisted data actually changed
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		myCatTableView.endUpdates()
	}
	
	// Actions taken when persisted data changes (dependent on CRUD action)
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		print("Object changed method called")
		switch (type) {
		case .insert:
			if let indexPath = newIndexPath {
				myCatTableView.insertRows(at: [indexPath], with: .fade)
			}
			break;
			
		case .delete:
			if let indexPath = indexPath {
				myCatTableView.insertRows(at: [indexPath], with: .fade)
			}
			break;
		
		case .move:
			break;
			
		case .update:
			break;
		@unknown default:
			break;
		}
	}
}

extension MyCatController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let count = CoreDataManager.sharedManager.fetchAllMyCats()?.count {
			return count
		}
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Fetch persisted data based on row
		let myCat = CoreDataManager.sharedManager.fetchedResultsControllerMyCat.object(at: indexPath)
		
		// Hash key to distinguish photos when caching to NSCache
		let key = "\(myCat.hash)" as NSString
		print("Hash key for \(myCat.name) is \(myCat.hash)")
		
		// Verify that photo actually exists before saving to cache
		var catPhoto: UIImage = UIImage()
		if let catPhotoCached = cachePhotos.object(forKey: key) {
			catPhoto = catPhotoCached
		} else {
			if let catPhotoData = myCat.catPhoto {
				catPhoto = UIImage(data: catPhotoData)!
				cachePhotos.setObject(catPhoto, forKey: key)
			}
		}
		
		// Fill cell
		let cell = tableView.dequeueReusableCell(withIdentifier: "myCatCell") as! MyCatTableViewCell
		cell.populateCell(catData: myCat, catPhoto: catPhoto)
		
		return cell
	}
}

extension UIViewController {
	// Sets up default color and text for Navigation Bar
	func setupNavigationBar() {
		navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "58cced")
		
		let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font: UIFont(name: "SFProRounded-Semibold", size: 20)!]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = .black
	}
	
	func highlightTagItem(_ tag: Int, _ tabBar: UITabBar) {
		tabBar.selectedItem = tabBar.items![tag] as UITabBarItem
	}
}
