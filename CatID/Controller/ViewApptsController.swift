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
		switch section {
		case 0:
			return myCat.upcomingAppointments?.events.count ?? 0
		case 1:
			return myCat.pastAppointments?.events.count ?? 0
		default:
			print("Error, unexpected section when listing appointments: \(section)")
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let myCat = CoreDataManager.sharedManager.fetchedResultsControllerMyCat.object(at: selectedCat!)
		let cell = tableView.dequeueReusableCell(withIdentifier: "myCatInfo") as! ApptsTableViewCell
		var appointment: Appointment?
		
		switch indexPath.section {
		case 0:
			if let upcomingAppt = myCat.upcomingAppointments?.events[indexPath.row] {
				appointment = upcomingAppt
			}
			break
		case 1:
			if let pastAppt = myCat.pastAppointments?.events[indexPath.row] {
				appointment = pastAppt
			}
			break
		default:
			print("Error, unexpected section when listing appointments: \(indexPath.section)")
		}
		
		// Retrieve data in a user-readable friendly format
		let startDate = appointment?.startDate
		let endDate = appointment?.endDate
		let apptFormat = "\(dateFormatter(orignalDate: startDate!)), \(timeFormatter(originalDate: startDate!))-\(timeFormatter(originalDate: endDate!))"
		
		cell.populateCell(date: apptFormat, location: getLocation(appointment), title: getTitle(appointment))
		
		// In case there's no title/location, refresh layout
		cell.contentView.setNeedsLayout()
		cell.contentView.layoutIfNeeded()
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Upcoming Appointments"
		case 1:
			return "Past Appointments"
		default:
			return ""
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let myCat = CoreDataManager.sharedManager.fetchedResultsControllerMyCat.object(at: selectedCat!)
		var appointment: Appointment?
		if indexPath.section == 0 {
			appointment = myCat.upcomingAppointments?.events[indexPath.row]
		} else if indexPath.section == 1 {
			appointment = myCat.pastAppointments?.events[indexPath.row]
		}
		
		displayCalendar(appointment)
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func getLocation(_ appointment: Appointment?) -> String? {
		guard let appointment = appointment else {
			return nil
		}
		
		let eventStore = EKEventStore()
		let event = eventStore.event(withIdentifier: appointment.identifier!)
		guard let location = event?.location else {
			return nil
		}
		return location
	}
	
	func getTitle(_ appointment: Appointment?) -> String? {
		guard let appointment = appointment, let eventId = appointment.identifier else {
			return nil
		}
		
		let eventStore = EKEventStore()
		let event = eventStore.event(withIdentifier: eventId)
		guard let title = event?.title else {
			return nil
		}
		return title
	}
}

//MARK: NSFetchedResultsControllerDelegate methods to handle local storage CRUD operations
extension ViewApptsController: NSFetchedResultsControllerDelegate {
	
}

// MARK: EKEventEditViewDelegate methods
extension ViewApptsController: EKEventEditViewDelegate {
	func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
		switch action {
		case .canceled:
			dismiss(animated: true, completion: nil)
		case .deleted:
			//TODO: Delete calendar event here
			break
		case .saved:
			//TODO: Update calendar event here
			break
		@unknown default:
			print("Unknown error from eventEditViewController delegate method, ViewApptsController")
		}
	}
	
	private func displayCalendar(_ appointment: Appointment?) {
		guard let appointment = appointment, let eventId = appointment.identifier else {
			print("displayCalendar method, appointment without identifier")
			return
		}
		let eventVC = EKEventEditViewController()
		eventVC.editViewDelegate = self
		eventVC.eventStore = EKEventStore()
		eventVC.event = eventVC.eventStore.event(withIdentifier: eventId)
		self.present(eventVC, animated: true)
	}
}
