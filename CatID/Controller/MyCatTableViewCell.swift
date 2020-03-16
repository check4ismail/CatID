//
//  MyCatTableViewCell.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/22/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

class MyCatTableViewCell: UITableViewCell {
	
	@IBOutlet weak var myCatPhoto: UIImageView!
	@IBOutlet weak var myCatName: UITextField!
	@IBOutlet weak var myCatBreed: UITextField!
	
	private let currentYear = Calendar.current.component(.year, from: Date())
	
	func populateCell(catData: MyCat, catPhoto: UIImage) {
		print("Populate cell was called here")
		DispatchQueue.main.async {
			self.myCatPhoto.image = catPhoto
			self.myCatName.text = catData.name
			self.myCatBreed.text = catData.breedType
		}
	}
	
//	private func calculateAge(month: String?, day: Int?, year: Int?) -> String? {
//		guard let year = year else {
//			return ""
//		}
//
//		if currentYear == year {
//
//		}
//	}
}
