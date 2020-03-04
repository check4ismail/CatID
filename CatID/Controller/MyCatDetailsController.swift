//
//  MyCatDetailsController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/28/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

class MyCatDetailsController: UIViewController, UpdateMyCatDelegate {

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var catDetailsTable: UIView!
	@IBOutlet weak var catImageView: UIImageView!
	@IBOutlet weak var defaultTextView: UITextView!
	
	let segue = "updateMyCat"
	var catDetailsTableVC: CatDetailsTableView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(catDetailsTable)
		
		fillNameAndImage()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		print("MyCatDetailsController appeared.......")
	}
	
	func fillNameAndImage() {
		nameTextField.text = MyCatData.myCat?.name
		
		guard let imageData = MyCatData.myCat?.catPhoto else {
			catImageView.isHidden = true
			return
		}
		
		if let image = UIImage(data: imageData) {
			catImageView.image = image
			defaultTextView.isHidden = true
		}
	}
	
	@IBAction func editButton(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: segue, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "viewCatOnly" { // Segue to container view
			CatDetailsTableView.segueIdentifier = "MyCatDetailsController"
			if let destinationVC = segue.destination as? CatDetailsTableView {
				catDetailsTableVC = destinationVC
			}
		} else { // Segue to modal view to edit cat
			if let destinationVC = segue.destination as? UpdateMyCat {
				destinationVC.delegate = self
			}
		}
	}
	
	// MARK: Delegate method of UpdateMyCatDelegate
	func updateMyCatModalDismissed() {
		fillNameAndImage()	// Update text fields in current view
		catDetailsTableVC?.populateTextFields()	// Update fields in catdetailstableview
	}
}
