//
//  ApptsTableViewCell.swift
//  CatID
//
//  Created by Ismail Elmaliki on 3/16/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

class ApptsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var locationTextView: UITextView!
	
	func populateCell(date: String, location: String?, title: String?) {
		DispatchQueue.main.async {
			self.dateLabel.text = date
			if let location = location {
				self.locationTextView.isHidden = false
				self.locationTextView.text = location
			} else {
				self.locationTextView.isHidden = true
			}
			
			if let title = title {
				self.titleLabel.isHidden = false
				self.titleLabel.text = title
			} else {
				self.titleLabel.isHidden = true
			}
		}
		self.setNeedsLayout()
	}
}
