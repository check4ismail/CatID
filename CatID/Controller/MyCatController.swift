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
	@IBOutlet weak var addButton: UIBarButtonItem!
	
	private let segueToBreedList = "catBreedSegue"
	private let segueToAddCat = "addCat"
	private let segueToDetails = "viewMyCat"
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
		displayCorrectSeparatorStyle()
		
		print("viewDidLoad from MyCatController")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		MyCatData.clearMyCat()
		myCatTableView.reloadData()
	}
	
	func displayCorrectSeparatorStyle() {
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
	
	@IBAction func addNewCat(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Add Cat", style: .default, handler: { (action: UIAlertAction) in
			self.performSegue(withIdentifier: self.segueToAddCat, sender: self)
		}))
		alert.addAction(UIAlertAction(title: "New Appointment", style: .default, handler: { (action: UIAlertAction) in
			print("I officially added a new appointment, boss")
		}))
		
		// Currently there's a bug in iOS 12-13
		// the bug presents UIAlertActionController from appearing directly from the button due
		// to "breaking constraints"
		self.present(alert, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == segueToAddCat {
			let addCatVC = segue.destination as! AddCatController
			addCatVC.delegate = self
		}
		
		if segue.identifier == segueToDetails {
			catInfoToDetailedView()
		}
		highlightTagItem(myCatTag, tabBar)
	}
	
	private func catInfoToDetailedView() {
		let selectedRow = myCatTableView.indexPathForSelectedRow
		let myCat = CoreDataManager.sharedManager.fetchedResultsControllerMyCat.object(at: selectedRow!)
		MyCatData.myCat = myCat
		myCatTableView.deselectRow(at: selectedRow!, animated: true)
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
		displayCorrectSeparatorStyle()
	}
	
	// Actions taken when persisted data changes (dependent on CRUD action)
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		print("Object changed method called: \(type.rawValue)")
		switch (type) {
		case .insert:
			if let indexPath = newIndexPath {
				myCatTableView.insertRows(at: [indexPath], with: .fade)
			}
			break;
			
		case .delete:
			if let deletedRow = indexPath {
				myCatTableView.deleteRows(at: [deletedRow], with: .automatic)
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		CatDetailsTableView.segueIdentifier = "MyCatDetailsController"
		performSegue(withIdentifier: segueToDetails, sender: self)
	}
	
	// MARK: Delete tableview functions
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			print("Deleted")
			let myCat = CoreDataManager.sharedManager.fetchedResultsControllerMyCat.object(at: indexPath)
			CoreDataManager.sharedManager.deleteMyCat(cat: myCat)
		}
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
