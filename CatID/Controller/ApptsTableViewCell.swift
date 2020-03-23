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
	
	@IBOutlet weak var titleHeight: NSLayoutConstraint!
	@IBOutlet weak var locationHeight: NSLayoutConstraint!
	
	let defaultLocationHeight: CGFloat = 82
	let defaultTitleHeight: CGFloat = 31
	
	func populateCell(date: String, location: String?, title: String?) {
		dateLabel.text = date
		
		// See if location if visible, otherwise shift its height
		if let location = location {
			locationHeight.constant = defaultLocationHeight
			locationTextView.text = location
		} else {
			print("Location is empty.....so it should be hidden")
			locationHeight.constant = 0
		}
		
		// See if title is available, otherwise shift its height
		if let title = title {
			titleHeight.constant = defaultTitleHeight
			titleLabel.text = title
		} else {
			titleHeight.constant = 0
		}
		
		// In case there's no title/location, refresh layout
		self.contentView.setNeedsLayout()
		self.contentView.layoutIfNeeded()
	}
}
