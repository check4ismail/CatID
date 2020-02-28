//
//  MyCatData.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/22/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import Foundation
import UIKit

struct MyCatData {
	var vetInfo: String?
	var notes: String?
	var name: String?
	var catPhoto: Data?
	var breedType: String?
	var birthdayYear: Int?
	var birthdayMonth: String?
	var birthdayDay: Int?
	
	static var data = MyCatData()
	private init() { }
	
	mutating func clearData() {
		vetInfo?.removeAll()
		notes?.removeAll()
		name?.removeAll()
		catPhoto?.removeAll()
		breedType?.removeAll()
		birthdayMonth?.removeAll()
		birthdayDay = nil
		birthdayYear = nil
	}
}
