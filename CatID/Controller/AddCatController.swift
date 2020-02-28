//
//  AddCatController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/27/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import CoreData

class AddCatController: UIViewController, UIPickerViewDataSource, NSFetchedResultsControllerDelegate {
	
	@IBOutlet weak var catName: UITextField!
	@IBOutlet weak var birthday: UITextField!
	@IBOutlet weak var breedType: UITextField!
	@IBOutlet weak var vetInfo: UITextView!
	@IBOutlet weak var notes: UITextView!
	@IBOutlet weak var catPhotoButton: UIButton!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	var delegate: MyCatController?
	
	private let breedPicker = UIPickerView()
	private let birthdayPicker = UIPickerView()
	
	private var selectedBreed: String = CatBreeds.breeds[0]
	private var selectedMonth: String = "January"
	private var selectedDay: Int = 1
	private var selectedYear: Int = Calendar.current.component(.year, from: Date())
	
	private var months = ["January", "February", "March", "April", "May", "June",
						  "July", "August", "September", "October", "November", "December"]
	private var days: [Int] = []
	private var leapYearDays: Int = 29
	private var years: [Int] = []
	
	private var backgroundPhotoExists = false
	
	override func viewDidLoad() {
		setupPicker()	// Setup picker for breed and birthday
		createToolBars() 	// Add toolbar to dismiss picker
		setupDaysAndYears()	// Setup number of years and days for birthday picker
		setupDelegates()	// Setup delegates for textview and textfield
	}
	
	override func viewDidAppear(_ animated: Bool) {
		defaultPickers()
	}
	
	@IBAction func uploadCatPhoto(_ sender: UIButton) {
		showAlert()
	}
	
	//Show alert
	func showAlert() {

		let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
			self.openCamera()
		}))
		alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
			self.openGallery()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	// MARK: Cancel button action
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		if areCatCardValuesAllNil() {
			self.dismiss(animated: true, completion: nil)
		} else {
			let alert = UIAlertController(title: "Are you sure you want to discard changes?", message: nil, preferredStyle: .actionSheet)
			alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {(action: UIAlertAction) in
				self.dismiss(animated: true, completion: nil)
			}))
			alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	// MARK: Done button action
	@IBAction func doneButton(_ sender: UIBarButtonItem) {
		save()
		self.dismiss(animated: true) {
			self.delegate?.modalDismissed()
		}
	}
	
	private func areCatCardValuesAllNil() -> Bool {
		
		if catName.text!.isEmpty &&
			birthday.text!.isEmpty &&
			breedType.text!.isEmpty &&
			vetInfo.text.isEmpty &&
			notes.text.isEmpty &&
			!backgroundPhotoExists {
			return true
		} else {
			return false
		}
	}
	
	// MARK: Saving to Core Data
	private func save() {
		
		if !catName.text!.isEmpty {
			MyCatData.data.name = catName.text!
		}
		if !breedType.text!.isEmpty {
			MyCatData.data.breedType = selectedBreed
		}
		if !birthday.text!.isEmpty {
			MyCatData.data.birthdayMonth = selectedMonth
			MyCatData.data.birthdayDay = selectedDay
			MyCatData.data.birthdayYear = selectedYear
		}
		
		MyCatData.data.notes = notes.text!
		MyCatData.data.vetInfo = vetInfo.text

		if backgroundPhotoExists {
			let image = catPhotoButton.currentBackgroundImage?.jpegData(compressionQuality: 0.3)
			MyCatData.data.catPhoto = image
		}
		
		CoreDataManager.sharedManager.insertMyCat()
	}
	
	func setupDelegates() {
		catName.delegate = self
		birthday.delegate = self
		breedType.delegate = self
		vetInfo.delegate = self
		notes.delegate = self
	}
	
	func doneButtonDisabledCheck() {
		if areCatCardValuesAllNil() {
			doneButton.isEnabled = false
		}
	}
	
	// Years will include 1950 to current year
	// Days will include 1 to 31
	func setupDaysAndYears() {
		let currentYear = Calendar.current.component(.year, from: Date())
		for i in 1950...currentYear {
			years.append(i)
		}
		years.reverse()
		for j in 1...31 {
			days.append(j)
		}
	}
	
	// MARK: Setting up pickerview for each birthday and breed textfields
	func setupPicker() {
		breedPicker.delegate = self
		birthdayPicker.delegate = self
		
		breedType.inputView = breedPicker
		birthday.inputView = birthdayPicker
		
		birthdayPicker.tag = 0
		breedPicker.tag = 1
	}
	
	func defaultPickers() {
		breedPicker.selectRow(0, inComponent: 0, animated: false)
		birthdayPicker.selectRow(0, inComponent: 0, animated: false)
		birthdayPicker.selectRow(0, inComponent: 1, animated: false)
		birthdayPicker.selectRow(0, inComponent: 2, animated: false)
	}
	
	func createToolBars() {
		let toolBar = [UIToolbar(), UIToolbar()]
		toolBar.forEach { $0.sizeToFit() }
		
		let doneButton =
			[UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddCatController.dismissKeyboardFromBreedPicker)),
			UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddCatController.dismissKeyboardFromBirthdayPicker))]
		
		for i in 0..<toolBar.count {
			toolBar[i].setItems([doneButton[i]], animated: false)
			toolBar[i].isUserInteractionEnabled = true
		}
		
		breedType.inputAccessoryView = toolBar[0]
		birthday.inputAccessoryView = toolBar[1]
	}
	
	// MARK: Keyboard dismiss methods, toolbars for each textview
	@objc
	func dismissKeyboardFromBreedPicker() {
		print("HERE")
		view.endEditing(true)
		// Once breed picker dismissed, set textview
		breedType.text = selectedBreed
	}
	
	@objc
	func dismissKeyboardFromBirthdayPicker() {
		view.endEditing(true)
		// Once birthday picker dismissed, set textview
		birthday.text = "\(selectedMonth) \(selectedDay), \(selectedYear)"
	}
	
	// MARK: Helper methods to calculate corresponding months, days, and years
	private func autoSelectMonth(_ pickerView: UIPickerView, _ row: Int) {
		let month = selectedMonth
		let day = selectedDay
		let year = selectedYear
		
		let dayForMonthRow = daysInSpecificMonth(month, year, row)
		if day == 30 || day == 31 || day == 29 {
			if month == "February" {
				pickerView.selectRow(dayForMonthRow, inComponent: 1, animated: true)
				selectedDay = days[dayForMonthRow]
			}
		}
		if day == 31 {
			if month == "April" || month == "June" || month == "September" || month == "November" {
				pickerView.selectRow(dayForMonthRow, inComponent: 1, animated: true)
				selectedDay = days[dayForMonthRow]
			}
		}
	}
	
	private func daysInSpecificMonth(_ month: String, _ year: Int, _ defaultRow: Int) -> Int {
		let thirtyFirstIndex = days.count - 1
		let thirtyIndex = thirtyFirstIndex - 1
		let twentyNinthIndex = thirtyIndex - 1
		let twentyEightIndex = twentyNinthIndex - 1
		
		switch month {
		case "April", "June", "September", "November":
			return thirtyIndex
		case "February":
			if leapYear(year) == leapYearDays {
				return twentyNinthIndex
			}
			return twentyEightIndex
		default:
			return defaultRow
		}
	}

	// Leap year calculation
	private func leapYear(_ year: Int) -> Int {
		let divisibleByFour: Bool = (year % 4) == 0
		let divisibleBy100: Bool = (year % 100) == 0
		let divisiblyBy400: Bool = (year % 400) == 0
		
		if divisibleBy100 {
			if divisiblyBy400 {
				return 29
			}
		} else {
			if divisibleByFour {
				return 29
			}
		}
		
		return 28
	}
}

// MARK: Image picker methods
extension AddCatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	// Photo selected from camera
	func openCamera() {

		//Check is source type available
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = UIImagePickerController.SourceType.camera
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	// Photo selected from photo library
	func openGallery() {
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.allowsEditing = true
			imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
			self.present(imagePicker, animated: true, completion: nil)
			
		} else {
			let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	// Setting the image once it has been selected by user
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if var pickedImage = info[.originalImage] as? UIImage {
			pickedImage = pickedImage.af_imageRoundedIntoCircle()
			catPhotoButton.setBackgroundImage(pickedImage, for: .normal)
			backgroundPhotoExists = true
		}
		picker.dismiss(animated: true, completion: nil)
	}
}

// MARK: Pickerview methods
extension AddCatController: UIPickerViewDelegate {
	
	// Values displayed in each row & column
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView.tag == 0 {
			if component == 0 {
				return months[row]
			} else if component == 1 {
				return "\(days[row])"
			} else {
				return "\(years[row])"
			}
		} else {
			return CatBreeds.breeds[row]
		}
	}
	
	// Action that occurs when a row is selected
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView.tag == 0 {
			/*
				If a month, day, or year is selected, a check is done
				to verify that a valid day corresponding to the month and year was selected.
				Otherwise it selects a valid day for the user.
				
				Example - if user selects 31 as the day for April, it scrolls back to 30
			*/
			if component == 0 {
				selectedMonth = months[row]
				autoSelectMonth(pickerView, row)
			} else if component == 1 {
				selectedDay = days[row]
				autoSelectMonth(pickerView, row)
			} else {
				selectedYear = years[row]
				autoSelectMonth(pickerView, row)
			}
		} else {
			selectedBreed = CatBreeds.breeds[row]
			print("Selected breed: \(selectedBreed)")
		}
	}
	
	// Number of columns
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if pickerView.tag == 0 {
			return 3
		} else {
			return 1
		}
	}
	
	// Number of rows
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView.tag == 0 {
			if component == 0 {
				return months.count
			} else if component == 1 {
				return days.count
			} else {
				return years.count
			}
		} else {
			return CatBreeds.breeds.count
		}
	}
}

// MARK: Textview & Textfield delegates
extension AddCatController: UITextFieldDelegate, UITextViewDelegate {
/*
	If textfield or textview values change, checking is in place to
	determine if Done button should be enabled.
	
	If current textfield/textview is empty and all others are also empty,
	then Done button will be disabled
*/
	func textFieldDidChangeSelection(_ textField: UITextField) {
		if !textField.text!.isEmpty {
			doneButton.isEnabled = true
		} else {
			doneButtonDisabledCheck()
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		
		if !textView.text!.isEmpty {
			doneButton.isEnabled = true
		} else {
			doneButtonDisabledCheck()
		}
	}
}
