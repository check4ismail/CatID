//
//  MyCatController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/22/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import EventKitUI
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
	private var selectedCatForAppt: Int?
	
	static var testDate: Date?
	static var testDateStore: EKEventStore?
	static var testEventId: String = ""
	static var formattedDate: String = ""
	
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
		// Setup appointment actionsheet option
		calendarSetup(alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
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
		MyCatData.data.selectedIndexPath = selectedRow
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

//MARK: NSFetchedResultsControllerDelegate methods to handle local storage CRUD operations
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
		print("Object changed method called: \(type)")
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
			print("Move called")
			break;
			
		case .update:
			myCatTableView.reloadData()
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

//MARK: Appointment creation methods that take place
extension MyCatController: EKEventEditViewDelegate {
	
	//MARK: Sets up uialert actionsheet of each cat to make an appointment
	private func calendarSetup(_ alert: UIAlertController) {
		// To setup an appointment, at least 1 cat should be present
		if let cats = CoreDataManager.sharedManager.fetchAllMyCats(), cats.count > 0 {
			let alertCatList = UIAlertController(title: "Appointment for which cat?", message: nil, preferredStyle: .actionSheet)
			for i in 0..<cats.count {
				alertCatList.addAction(UIAlertAction(title: cats[i].name, style: .default, handler: { action in
					// Set selectedCatForAppt to row number
					self.selectedCatForAppt = i
					self.authorizeCalendar()
				}))
			}
			alertCatList.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "New Appointment", style: .default, handler: { (action: UIAlertAction) in
				self.present(alertCatList, animated: true)
			}))
		}
	}
		
	private func authorizeCalendar() {
		switch EKEventStore.authorizationStatus(for: .event) {
		case .notDetermined:
			let eventStore = EKEventStore()
			eventStore.requestAccess(to: .event) { (granted, error) in
				if granted {
					DispatchQueue.main.async {
						self.displayCalender()
					}
				} else {	// If access to calendar is not granted, display auth message
					self.calendarNeedsAuthAlert()
				}
			}
		case .authorized:
			self.displayCalender()
		default:	// If explicitly denied access previously, display auth message
			calendarNeedsAuthAlert()
			break
		}
	}
		
	private func calendarNeedsAuthAlert() {
		DispatchQueue.main.async {
			let alert = UIAlertController(title: "Calendar Not Authorized", message: "Adjust your privacy settings so CatID can access your calendar to create an appointment", preferredStyle: .alert)
			// Directs user to Settings of app to enable calendar authorization
			alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
					return
				}
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						print("Settings opened: \(success)") // Prints true
					})
				}
			}))
			// Cancel button
			alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
			// Present alert
			self.present(alert, animated: true)
		}
	}
		
	private func displayCalender() {
		// Setup event view controller
		let eventVC = EKEventEditViewController()
		eventVC.editViewDelegate = self
		eventVC.eventStore = EKEventStore()
		present(eventVC, animated: true)
	}
	
//	@IBAction func editCalendar(_ sender: UIButton) {
//		//TODO: Wrap up editing a calendar event
//		let eventVC = EKEventEditViewController()
//		eventVC.editViewDelegate = self
//		let eventStore = EKEventStore()
//		eventVC.eventStore = eventStore
//		eventVC.event = eventStore.event(withIdentifier: MyCatController.testEventId)
//		present(eventVC, animated: true)
//	}
	
	func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
		switch action {
		case .canceled:
			print("Canceled event")
			dismiss(animated: true, completion: nil)
			break
		case .saved:
			print("Trying to save event")
			// Verify event, startDate, and row are not nil
			if let event = controller.event,
			let startDate = event.startDate,
			let row = selectedCatForAppt {
				// Setup appointment structure
				let appointment = Appointment(startDate: event.startDate, endDate: event.endDate, identifier: event.eventIdentifier)
				
				if startDate >= Date() {	// Persist appt as upcoming appt via CoreData
					CoreDataManager.sharedManager.saveUpcomingAppts([appointment], row)
				} else { // Persist appt as past appt via CoreData
					CoreDataManager.sharedManager.savePastAppts([appointment], row)
				}
			}
			dismiss(animated: true, completion: nil)
			break
		case .deleted:
			print("Event deleted")
			break
		@unknown default:
			print("Another option other than deleted, saved, canceled was selected")
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
	
	// Changes date to a more readable format
	func dateFormatter(orignalDate: Date) -> String {
		let format = DateFormatter()
		format.timeZone = .current
		format.locale = .current
		format.amSymbol = "AM"
		format.pmSymbol = "PM"
		format.dateFormat = "MM-dd-yyyy"
		return format.string(from: orignalDate)
	}
	
	func timeFormatter(originalDate: Date) -> String {
		let format = DateFormatter()
		format.timeZone = .current
		format.locale = .current
		format.amSymbol = "AM"
		format.pmSymbol = "PM"
		format.dateFormat = "hh:mma"
		return format.string(from: originalDate)
	}
}
