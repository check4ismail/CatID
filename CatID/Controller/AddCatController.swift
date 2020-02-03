//
//  AddCatController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/27/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Firebase

class AddCatController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet weak var birthday: UITextField!
	@IBOutlet weak var breedType: UITextField!
	
	private let breedPicker = UIPickerView()
	private let birthdayPicker = UIPickerView()
	
	private var selectedBreed: String = CatBreeds.breeds[0]
	private var selectedMonth: String = "January"
	private var selectedDay: Int = 1
	private var selectedYear: Int = Calendar.current.component(.year, from: Date())
	
	private var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	private var days: [Int] = []
	private var leapYearDays: Int = 29
	private var years: [Int] = []
	
	override func viewDidLoad() {
		setupPicker()	// Setup picker for breed and birthday
		createToolBars() 	// Add toolbar to dismiss picker
		setupDaysAndYears()	// Setup number of years and days for birthday picker
	}
	
	override func viewDidAppear(_ animated: Bool) {
		defaultPickers()
	}
	
	// MARK: Cancel button action
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: Done button action
	@IBAction func doneButton(_ sender: UIBarButtonItem) {
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
	
	// MARK: Pickerview methods
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
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView.tag == 0 {
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
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if pickerView.tag == 0 {
			return 3
		} else {
			return 1
		}
	}
	
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

