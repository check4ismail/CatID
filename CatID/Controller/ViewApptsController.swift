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
	let eventVC = EKEventEditViewController()
	
	var selectedCat: IndexPath?
	var selectedAppointment: IndexPath?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		shiftUpcomingApptToPast()
		selectedCat = MyCatData.data.selectedIndexPath
		
		catInfoTableView.delegate = self
		catInfoTableView.dataSource = self
		
		eventVC.eventStore = EKEventStore()
		
		print("Number of rows in upcoming appointment prior to deletion: \(MyCatData.myCat?.upcomingAppointments?.events.count)")
		print("Number of rows in past appointment prior to deletion: \(MyCatData.myCat?.pastAppointments?.events.count)")
    }
	
	// Because upcoming appointments is sorted by most recent date,
	// this function checks last element - if it's no longer an upcoming event it's appended to past appointments
	// An event is considered 'upcoming' if it's >= current Date()
	func shiftUpcomingApptToPast() {
		var isOutdated = true
		while let upcomingAppt = MyCatData.myCat?.upcomingAppointments?.events.first, isOutdated {
			if upcomingAppt.startDate! < Date() {
				MyCatData.myCat?.pastAppointments?.events.insert(upcomingAppt, at: 0)
				MyCatData.myCat?.upcomingAppointments?.events.removeLast()
				isOutdated = true
			} else {
				isOutdated = false
			}
		}
		
		MyCatData.myCat?.pastAppointments?.events.sort(by: >)
		CoreDataManager.sharedManager.updateMyCat()
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
		
		selectedAppointment = indexPath
		displayCalendar(appointment)
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Fetch eventId from indexpath
			var eventId: String?
			if indexPath.section == 0 {
				eventId = MyCatData.myCat?.upcomingAppointments?.events[indexPath.row].identifier
			} else if indexPath.section == 1 {
				eventId = MyCatData.myCat?.pastAppointments?.events[indexPath.row].identifier
			}
			
			// Attempt to remove calendar event - if successful, proceed with removing appt data locally
			let eventStore = EKEventStore()
			if let eventId = eventId, let event = eventStore.event(withIdentifier: eventId) {
				do {
					print("Attempt to remove calendar event")
					try eventStore.remove(event, span: .thisEvent, commit: true)
					print("Successfully removed calendar event")
					deleteAppointment(atIndexPath: indexPath)
				} catch {
					print("Error trying to remove event: \(error)")
				}
			}
		}
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

// MARK: EKEventEditViewDelegate methods
extension ViewApptsController: EKEventEditViewDelegate {
	
	func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
		print("eventEditViewController called")
		eventVC.editViewDelegate = nil
		switch action {
		case .canceled:
			controller.dismiss(animated: true, completion: nil)
		case .deleted:
			deleteAppointment()
			controller.dismiss(animated: true, completion: nil)
		case .saved:
			updateAppointment(updatedEvent: controller.event)
			catInfoTableView.reloadData()
			controller.dismiss(animated: true, completion: nil)
		@unknown default:
			print("Unknown error from eventEditViewController delegate method, ViewApptsController")
		}
	}
	
	private func updateAppointment(updatedEvent: EKEvent?) {
		guard let selectedAppointment = selectedAppointment,
			let event = updatedEvent else { return }
		
		let row = selectedAppointment.row
		switch selectedAppointment.section {
		case 0:
			// Update selected upcoming appointment data
			MyCatData.myCat?.upcomingAppointments?.events[row].identifier = event.eventIdentifier
			MyCatData.myCat?.upcomingAppointments?.events[row].startDate = event.startDate
			MyCatData.myCat?.upcomingAppointments?.events[row].endDate = event.endDate
			
			// IF: upcoming appointment turns out to be a past appointment, add it to past appointment
			// then remove it from upcoming appointments
			// ELSE: simply sort upcoming appointments
			if event.startDate < Date() {
				let pastAppt = MyCatData.myCat?.upcomingAppointments?.events[row]
				MyCatData.myCat?.pastAppointments?.events.append(pastAppt!)
				MyCatData.myCat?.pastAppointments?.events.sort(by: >)
				
				MyCatData.myCat?.upcomingAppointments?.events.remove(at: row)
			} else {
				MyCatData.myCat?.upcomingAppointments?.events.sort(by: <)
			}
			break
		case 1:
			// Update selected past appointment data
			MyCatData.myCat?.pastAppointments?.events[row].identifier = event.eventIdentifier
			MyCatData.myCat?.pastAppointments?.events[row].startDate = event.startDate
			MyCatData.myCat?.pastAppointments?.events[row].endDate = event.endDate
			
			// IF: past appointment turns out to be an upcoming appointment, add it to upcoming appointment
			// then remove it from past appointments
			// ELSE: simply sort past appointments
			if event.startDate > Date() {
				let upcomingAppt = MyCatData.myCat?.pastAppointments?.events[row]
				MyCatData.myCat?.upcomingAppointments?.events.append(upcomingAppt!)
				MyCatData.myCat?.upcomingAppointments?.events.sort(by: <)
				
				MyCatData.myCat?.pastAppointments?.events.remove(at: row)
			} else {
				MyCatData.myCat?.pastAppointments?.events.sort(by: >)
			}
			break
		default:
			print("Error - updateAppointment method returned invalid section: \(selectedAppointment.section)")
		}
		
		CoreDataManager.sharedManager.updateAppts()
	}
	
	private func deleteAppointment(atIndexPath: IndexPath? = nil) {
		let row: Int
		let section: Int
		if let indexPath = atIndexPath {
			row = indexPath.row
			section = indexPath.section
		} else {
			row = selectedAppointment!.row
			section = selectedAppointment!.section
		}
		
		print("Delete appointment method is executing")
		print("Current value of section: \(section)")
		print("Current value of row: \(row)")
		switch section {
		case 0:
			print("Number of rows in upcoming appointment prior to deletion: \(MyCatData.myCat?.upcomingAppointments?.events.count)")
			MyCatData.myCat?.upcomingAppointments?.events.remove(at: row)
			CoreDataManager.sharedManager.deleteAppt(type: .upcoming)
			break
		
		case 1:
			print("Number of rows in past appointment prior to deletion: \(MyCatData.myCat?.pastAppointments?.events.count)")
			MyCatData.myCat?.pastAppointments?.events.remove(at: row)
			CoreDataManager.sharedManager.deleteAppt(type: .past)
			break
			
		default:
			print("Error - deleteAppointment method returned invalid section: \(section)")
		}
		
		let indexPath : IndexPath = [section, row]
		catInfoTableView.deleteRows(at: [indexPath], with: .automatic)
	}
	
	private func displayCalendar(_ appointment: Appointment?) {
		guard let appointment = appointment, let eventId = appointment.identifier else {
			print("displayCalendar method, appointment without identifier")
			return
		}
		eventVC.editViewDelegate = self
		eventVC.event = eventVC.eventStore.event(withIdentifier: eventId)
		self.present(eventVC, animated: true)
	}
}
