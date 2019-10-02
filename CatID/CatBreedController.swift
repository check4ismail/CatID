//
//  CatBreedController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/28/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class CatBreedController: UIViewController {
	
	
	@IBOutlet weak var catImage: UIImageView!
	@IBOutlet var temperament: UITextView!
	
	@IBOutlet weak var childFriendlyTextField: UITextField!
	@IBOutlet weak var groomingTextField: UITextField!
	@IBOutlet weak var lapTextField: UITextField!
	@IBOutlet weak var sheddingTextField: UITextField!
	
	@IBOutlet weak var childRatingTextField: UITextField!
	@IBOutlet weak var groomingRatingTextField: UITextField!
	@IBOutlet weak var lapRatingTextField: UITextField!
	@IBOutlet weak var sheddingRatingTextField: UITextField!
	
	var selectedBreed: String?
	let bulletPoint: String = "🔵 "
	
	private var breedUrl = "https://api.thecatapi.com/v1/breeds/search?q="
	private var imageUrl = "https://api.thecatapi.com/v1/images/search?breed_id="
	
	private let headers: HTTPHeaders = [
		"x-api-key": "d88df8ce-6c21-4cb1-9253-bb6035eec8b8"
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.title = selectedBreed
		
		if let breed = selectedBreed {
			breedUrl = breedUrl + breed
				getCatInfo()
		}
	}
	
	func getCatInfo() {
		Alamofire.request(breedUrl, method: .get, headers: self.headers).validate().responseJSON { response in
			switch response.result {
			
			case .success(let value):
				let json = JSON(value)
				
				DispatchQueue.main.async(execute: {
					if let breedId = json[0,"id"].string {
						self.imageUrl = self.imageUrl + breedId
						self.getCatPhoto()
					}
					if let temperament = json[0,"temperament"].string,
						let childFriendly = json[0,"child_friendly"].int,
						let grooming = json[0,"grooming"].int,
						let lap = json[0,"lap"].int,
						let sheddingLevel = json[0,"shedding_level"].int
					{
						self.temperament.text = temperament
						
						self.fillRating([Int](arrayLiteral: childFriendly, grooming, lap, sheddingLevel))
					}
				})
			
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func getCatPhoto() {
		Alamofire.request(imageUrl, method: .get, headers: self.headers).validate().responseJSON { response in
			switch response.result {
			
			case .success(let value):
				let json = JSON(value)
			
				DispatchQueue.main.async {
					if let imageUrl = json[0,"url"].string {
						let downloadURL = NSURL(string: imageUrl)!
						self.catImage.af_setImage(withURL: downloadURL as URL)
					}
				}
			
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func fillRating(_ ratingArray: [Int]) {
		let arrayEnableTextFields: [UITextField] = [childFriendlyTextField, groomingTextField, lapTextField, sheddingTextField]
		let ratingTextFields: [UITextField] = [childRatingTextField, groomingRatingTextField, lapRatingTextField, sheddingRatingTextField]
		
		for i in 0..<ratingArray.count {
			arrayEnableTextFields[i].isHidden = false
			
			for _ in 0..<ratingArray[i] {
				if let ratingText = ratingTextFields[i].text {
					ratingTextFields[i].text = ratingText + bulletPoint
				}
			}
		}
	}
}
