//
//  CatDetailsTableView.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/28/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

protocol CatDetailsTableDelegate {
	func doneButtonIsEnabled()
	func updateBreed(_ breed: String)
	func updateBirthday(_ month: String, _ day: Int64, _ year: Int64)
	func updateNotes(_ notes: String)
	func updateVetInfo(_ vetInfo: String)
}

class CatDetailsTableView: UITableViewController {

	@IBOutlet weak var breedTextField: UITextField!
	@IBOutlet weak var birthdayTextField: UITextField!
	@IBOutlet weak var vetInfoTextField: UITextView!
	@IBOutlet weak var notesTextField: UITextView!
	
	static var segueIdentifier: String?
	static var breedChanged = false
	static var birthdayChanged = false
	static var vetInfoChanged = false
	static var notesChanged = false
	
	var delegate: CatDetailsTableDelegate?
	
	let breedPicker = UIPickerView()
	let birthdayPicker = UIPickerView()
	
	var selectedBreed: String = CatBreeds.breeds[0]
	var selectedMonth: String = "January"
	var selectedDay = 1
	var selectedYear = Calendar.current.component(.year, from: Date())
	
	var months: [String] = []
	var days: [Int] = []
	var years: [Int] = []
	
	private let fromMyCatDetails = "MyCatDetailsController"
	private let fromUpdateMyCat = "UpdateMyCat"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		populateTextFields()
		print("Current value of segue identifier is: \(CatDetailsTableView.segueIdentifier)")
		if CatDetailsTableView.segueIdentifier == fromMyCatDetails {
			print("from \(fromMyCatDetails)")
			viewTextFieldsOnly()
		} else {
			print("from \(fromUpdateMyCat)")
			viewAndEditTextFields()		// Allow textfields and textviews to be editable
			displayPlaceHolderText()	// Display placeholder for textviews
			
			setupPickers()	// Setup picker for breed and birthday
			createToolBars() 	// Add toolbar to dismiss picker
			
			// Setup months, number of years, and days for birthday picker
			months = setupMonths()
			years = setupYears()
			days = setupDays()
		}
		
		breedTextField.delegate = self
		birthdayTextField.delegate = self
		vetInfoTextField.delegate = self
		notesTextField.delegate = self
    }
	
	func populateTextFields() {
		print("populateTextFields was called")
		breedTextField.text = MyCatData.myCat?.breedType
		vetInfoTextField.text = MyCatData.myCat?.vetInfo
		notesTextField.text = MyCatData.myCat?.notes
		if let month = MyCatData.myCat?.birthdayMonth,
			let day = MyCatData.myCat?.birthdayDay,
			let year = MyCatData.myCat?.birthdayYear {
			birthdayTextField.text = "\(month) \(day), \(year)"
		}
	}
	
	func viewTextFieldsOnly() {
		breedTextField.isUserInteractionEnabled = false
		birthdayTextField.isUserInteractionEnabled = false
		vetInfoTextField.isEditable = false
		notesTextField.isEditable = false
	}
	
	func viewAndEditTextFields() {
		breedTextField.isUserInteractionEnabled = true
		birthdayTextField.isUserInteractionEnabled = true
		vetInfoTextField.isEditable = true
		notesTextField.isEditable = true
	}
	
	func displayPlaceHolderText() {
		breedTextField.placeholder = "Select breed"
		birthdayTextField.placeholder = "Select birthday"
	}
	
	// MARK: Get methods for breed, birthday, vetinfo, and notes
	private func getBreed() -> String {
		guard let breed = MyCatData.myCat?.breedType else {
			return ""
		}
		
		return breed
	}
	
	private func getBirthday() -> String {
		guard let month = MyCatData.myCat?.birthdayMonth,
		let day = MyCatData.myCat?.birthdayDay,
		let year = MyCatData.myCat?.birthdayYear else {
			return ""
		}
		
		return "\(month) \(day), \(year)"
	}
	
	private func getVetInfo() -> String {
		guard let vetInfo = MyCatData.myCat?.vetInfo else {
			return ""
		}
		
		return vetInfo
	}
	
	private func getNotes() -> String {
		guard let notes = MyCatData.myCat?.notes else {
			return ""
		}
		
		return notes
	}
}

extension CatDetailsTableView: UITextFieldDelegate, UITextViewDelegate {
	
	// MARK: Delegate methods for textview and textfield
	func textFieldDidChangeSelection(_ textField: UITextField) {
		if textField.tag == 0 { // Breed
			let breedType = getBreed()
			
			if textField.text != breedType {
				CatDetailsTableView.breedChanged = true
				delegate?.updateBreed(textField.text!)
			} else {
				print("Breed did not change")
				CatDetailsTableView.breedChanged = false
			}
		} else { // Birthday
			let birthday = getBirthday()
			if textField.text != birthday {
				CatDetailsTableView.birthdayChanged = true
				delegate?.updateBirthday(selectedMonth, Int64(selectedDay), Int64(selectedYear))
			} else {
				CatDetailsTableView.birthdayChanged = false
			}
		}
		delegate?.doneButtonIsEnabled()
	}
	
	func textViewDidChangeSelection(_ textView: UITextView) {
		if textView.tag == 0 {
			let vetInfo = getVetInfo()
			if textView.text != vetInfo {
				CatDetailsTableView.vetInfoChanged = true
				delegate?.updateVetInfo(textView.text!)
			} else {
				CatDetailsTableView.vetInfoChanged = false
			}
		} else {
			let notes = getNotes()
			if textView.text != notes {
				CatDetailsTableView.notesChanged = true
				delegate?.updateNotes(textView.text!)
			} else {
				CatDetailsTableView.notesChanged = false
			}
		}
		
		delegate?.doneButtonIsEnabled()
	}
}

extension CatDetailsTableView: UIPickerViewDataSource, UIPickerViewDelegate {
	
	// MARK: Helper methods to setup UIPickerView and toolbars
	func setupPickers() {
		breedPicker.delegate = self
		birthdayPicker.delegate = self
		
		breedTextField.inputView = breedPicker
		birthdayTextField.inputView = birthdayPicker
		
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
			[UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CatDetailsTableView.dismissKeyboardFromBreedPicker)),
			UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CatDetailsTableView.dismissKeyboardFromBirthdayPicker))]
		
		for i in 0..<toolBar.count {
			toolBar[i].setItems([doneButton[i]], animated: false)
			toolBar[i].isUserInteractionEnabled = true
		}
		
		breedTextField.inputAccessoryView = toolBar[0]
		birthdayTextField.inputAccessoryView = toolBar[1]
	}
	
	// MARK: Keyboard dismiss methods, toolbars for each textview
	@objc
	func dismissKeyboardFromBreedPicker() {
		view.endEditing(true)
		// Once breed picker dismissed, set textview
		breedTextField.text = selectedBreed
		textFieldDidChangeSelection(breedTextField)
	}
	
	@objc
	func dismissKeyboardFromBirthdayPicker() {
		view.endEditing(true)
		// Once birthday picker dismissed, set textview
		birthdayTextField.text = "\(selectedMonth) \(selectedDay), \(selectedYear)"
		textFieldDidChangeSelection(birthdayTextField)
	}
	
	// Checks that correct day is chosen for the month and year selected
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
	
	//MARK: Pickerview delegate methods
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
