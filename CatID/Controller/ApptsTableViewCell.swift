//
//  ApptsTableViewCell.swift
//  CatID
//
//  Created by Ismail Elmaliki on 3/16/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

class ApptsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var locationTextView: UITextView!
	
	func populateCell(date: String, location: String?) {
		DispatchQueue.main.async {
			//TODO: Fill date cell and location cell here
		}
	}
}
