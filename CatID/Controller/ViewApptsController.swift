//
//  ViewAppointmentsController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 3/16/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import CoreData
import EventKitUI

class ViewApptsController: UIViewController {

	@IBOutlet weak var catInfoTableView: UITableView!
	
	let segue = "updateMyCat"
	var selectedCat: IndexPath?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		catInfoTableView.delegate = self
		catInfoTableView.dataSource = self
		
		selectedCat = MyCatData.data.selectedIndexPath
    }
	
	@IBAction func editCatDetails(_ sender: UIButton) {
		self.performSegue(withIdentifier: segue, sender: self)
	}
	
	@IBAction func doneButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

// MARK: Tableview methods
extension ViewApptsController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let myCat = CoreDataManager.sharedManager.fetchedResultsControllerMyCat.object(at: selectedCat!)
		if section == 0 {
			return myCat.upcomingAppointments?.events.count ?? 0
		} else {
			return myCat.pastAppointments?.events.count ?? 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let myCat = CoreDataManager.sharedManager.fetchedResultsControllerMyCat.object(at: selectedCat!)
		let cell = tableView.dequeueReusableCell(withIdentifier: "myCatInfo") as! ApptsTableViewCell
		
		//TODO: This is how I'll be distinguishing between the upcoming and past appointments
		switch indexPath.section {
		case 0:
			<#code#>
		case 1:
			<#code#>
		default:
			print("Error, unexpected section when listing appointments: \(indexPath.section)")
		}
		return cell
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return ["Upcoming Appointments", "Past Appointments"]
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
}

//MARK: NSFetchedResultsControllerDelegate methods to handle local storage CRUD operations
extension ViewApptsController: NSFetchedResultsControllerDelegate {
	
}
