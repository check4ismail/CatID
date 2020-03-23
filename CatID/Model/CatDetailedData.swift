//
//  CatDetailedData.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/27/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import Foundation
import UIKit

/*
	Static variable of CatDetailedData is used between several view controllers
	without the need to rely on Protocols or other means
*/
struct CatDetailedData {
	var wikiLink: String?
	var temperament: String?
	var summaryText: String?
	var socialNeedsRating: String?
	var sheddingRating: String?
	var intelligenceRating: String?
	var imageUrl: String?
	var groomingRating: String?
	var childFriendlyRating: String?
	var breed: String?
	
	static var data = CatDetailedData()
	
	private init() { }
	
	mutating func setData(_ wikiLink: String,
						  _ temperament: String,
						  _ summaryText: String,
						  _ socialNeedsRating: String?,
						  _ sheddingRating: String?,
						  _ intelligenceRating: String?,
						  _ imageUrl: String?,
						  _ groomingRating: String?,
						  _ childFriendlyRating: String?,
						  _ breed: String) {
		self.wikiLink = wikiLink
		self.temperament = temperament
		self.summaryText = summaryText
		self.socialNeedsRating = socialNeedsRating
		self.sheddingRating = sheddingRating
		self.intelligenceRating = intelligenceRating
		self.imageUrl = imageUrl
		self.groomingRating = groomingRating
		self.childFriendlyRating = childFriendlyRating
		self.breed = breed
	}
	
	mutating func clearData() {
		wikiLink?.removeAll()
		temperament?.removeAll()
		summaryText?.removeAll()
		socialNeedsRating?.removeAll()
		sheddingRating?.removeAll()
		intelligenceRating?.removeAll()
		imageUrl?.removeAll()
		groomingRating?.removeAll()
		childFriendlyRating?.removeAll()
		breed?.removeAll()
	}
}
