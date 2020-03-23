//
//  UpdateMyCat.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/29/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

protocol UpdateMyCatDelegate {
	func updateMyCatModalDismissed()
}

class UpdateMyCat: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBOutlet weak var buttonImage: UIButton!
	@IBOutlet weak var catNameTextField: UITextField!
	@IBOutlet weak var catDetailsTableView: UIView!
	
	var delegate: UpdateMyCatDelegate?
	
	var photoChanged = false
	var catNameChanged = false
	
	var updatedBreedText = ""
	var updatedBirthdayMonth = ""
	var updatedBirthdayDay: Int64 = 0
	var updatedBirthdayYear: Int64 = 0
	var updatedVetInfoText = ""
	var updatedNotesText = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.addSubview(catDetailsTableView)	// Add container view, static tableview
		
		if let catImageData = MyCatData.myCat?.catPhoto {
			let catImage = UIImage(data: catImageData)
			buttonImage.setBackgroundImage(catImage, for: .normal)
		}
		catNameTextField.text = MyCatData.myCat?.name
		catNameTextField.placeholder = "Enter cat name"
		catNameTextField.delegate = self
    }
    
	@IBAction func buttonAction(_ sender: UIButton) {
		showAlert()	// Re-usable alert to select photo
	}
	
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func doneButton(_ sender: UIBarButtonItem) {
		save()
		delegate?.updateMyCatModalDismissed()
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: Save updated cat info to core data
	private func save() {
		
		if catNameChanged {
			MyCatData.myCat?.name = catNameTextField.text
		}
		if photoChanged {
			let image = buttonImage.currentBackgroundImage?.jpegData(compressionQuality: 0.3)
			MyCatData.myCat?.catPhoto = image
		}
		if CatDetailsTableView.breedChanged {
			MyCatData.myCat?.breedType = updatedBreedText
		}
		
		if CatDetailsTableView.birthdayChanged {
			MyCatData.myCat?.birthdayMonth = updatedBirthdayMonth
			MyCatData.myCat?.birthdayDay = updatedBirthdayDay
			MyCatData.myCat?.birthdayYear = updatedBirthdayYear
		}
		
		if CatDetailsTableView.notesChanged {
			MyCatData.myCat?.notes = updatedNotesText
		}
		
		if CatDetailsTableView.vetInfoChanged {
			MyCatData.myCat?.vetInfo = updatedVetInfoText
		}
		
		CoreDataManager.sharedManager.updateMyCat()
	}
	
	private func didAnyFieldChange() -> Bool {
		guard !photoChanged && !catNameChanged &&
			!CatDetailsTableView.breedChanged &&
			!CatDetailsTableView.birthdayChanged &&
			!CatDetailsTableView.vetInfoChanged &&
			!CatDetailsTableView.notesChanged else {
			return true
		}
		return false
	}
	
	// MARK: textfield delegate method
	func textFieldDidChangeSelection(_ textField: UITextField) {
		let catName = getCatName()
		if textField.text != catName {
			catNameChanged = true
		} else {
			catNameChanged = false
		}
		
		doneButtonIsEnabled()
	}
	
	private func getCatName() -> String {
		guard let catName = MyCatData.myCat?.name else {
			return ""
		}
		
		return catName
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		CatDetailsTableView.segueIdentifier = "UpdateMyCat"
		if let destinationVC = segue.destination as? CatDetailsTableView {
			destinationVC.delegate = self
		}
	}
}

// MARK: CatDetailsTableDelegate methods
extension UpdateMyCat: CatDetailsTableDelegate {
	func updateBreed(_ breed: String) {
		updatedBreedText = breed
	}
	
	func updateBirthday(_ month: String, _ day: Int64, _ year: Int64) {
		updatedBirthdayMonth = month
		updatedBirthdayDay = day
		updatedBirthdayYear = year
	}
	
	func updateNotes(_ notes: String) {
		updatedNotesText = notes
	}
	
	func updateVetInfo(_ vetInfo: String) {
		updatedVetInfoText = vetInfo
	}
	
	func doneButtonIsEnabled() {
		doneButton.isEnabled = didAnyFieldChange()
	}
}

// MARK: imagePickerController method specific to UpdateMyCat
extension UpdateMyCat {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if var pickedImage = info[.originalImage] as? UIImage {
			pickedImage = pickedImage.af_imageRoundedIntoCircle()
			buttonImage.setBackgroundImage(pickedImage, for: .normal)
			photoChanged = true
		}
		picker.dismiss(animated: true, completion: {
			self.doneButtonIsEnabled()
		})
	}
}
