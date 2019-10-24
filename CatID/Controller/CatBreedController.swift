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
	@IBOutlet weak var temperament: UITextView!
	@IBOutlet weak var summaryTextView: UITextView!
	
	@IBOutlet weak var childFriendlyTextField: UITextField!
	@IBOutlet weak var groomingTextField: UITextField!
	@IBOutlet weak var intelligenceTextField: UITextField!
	@IBOutlet weak var sheddingTextField: UITextField!
	@IBOutlet weak var socialNeedsTextField: UITextField!
	
	@IBOutlet weak var childRatingTextField: UITextField!
	@IBOutlet weak var groomingRatingTextField: UITextField!
	@IBOutlet weak var intelligenceRatingTextField: UITextField!
	@IBOutlet weak var sheddingRatingTextField: UITextField!
	@IBOutlet weak var socialNeedsRatingTextField: UITextField!
	
	@IBOutlet weak var wikiTextView: UITextView!
	
	@IBOutlet weak var noInternetView: UIView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var contentView: UIView!
	
	
	var selectedBreed: String?
	let bulletPoint: String = "🔵 "
	
	private let catApi = CatApi()
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
		
		// By default, views are hidden
		setAllViewsInvisible()
		if Connectivity.isConnectedToInternet {
			// If connected to internet, display as expected
			if var breed = selectedBreed {
				scrollView.isHidden = false
				contentView.isHidden = false
				breed = breed.replacingOccurrences(of: " ", with: "_")
				breedUrl = breedUrl + breed
				getCatInfo()
			}
		} else {	// No internet view displayed
			noInternetView.isHidden = false
		}
	}
	
	func setAllViewsInvisible() {
		noInternetView.isHidden = true
		scrollView.isHidden = true
		contentView.isHidden = true
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
						print("Getting that breedid")
					}
					print("Before filling temperament")
					if let temperament = json[0,"temperament"].string,
						let childFriendly = json[0,"child_friendly"].int,
						let grooming = json[0,"grooming"].int,
						let intelligence = json[0,"intelligence"].int,
						let sheddingLevel = json[0,"shedding_level"].int,
						let socialNeeds = json[0,"social_needs"].int,
						let description = json[0,"description"].string,
						let wikiLink = json[0,"wikipedia_url"].string
					{
						self.temperament.text = temperament
						self.fillRatings([Int](arrayLiteral: childFriendly, grooming, intelligence, sheddingLevel, socialNeeds))
						self.setWikiLink(wikiLink)
						self.summaryTextView.text = description
						self.summaryTextView.isHidden = false
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
						print("Filling cat photo")
					}
				}
			
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func fillRatings(_ ratingArray: [Int]) {
		let arrayEnableTextFields: [UITextField] = [childFriendlyTextField, groomingTextField, intelligenceTextField, sheddingTextField, socialNeedsTextField]
		let ratingTextFields: [UITextField] = [childRatingTextField, groomingRatingTextField, intelligenceRatingTextField, sheddingRatingTextField, socialNeedsRatingTextField]
		
		for i in 0..<ratingArray.count {
			arrayEnableTextFields[i].isHidden = false
			
			for _ in 0..<ratingArray[i] {
				if let ratingText = ratingTextFields[i].text {
					ratingTextFields[i].text = ratingText + bulletPoint
				}
			}
		}
	}
	
	func setWikiLink(_ wikiLink: String) {
		let url = URL(string: wikiLink)!
		
		// Setting up hyperlink, with specific font size
		let stringWithAttribute = NSMutableAttributedString(string: "WIKIPEDIA", attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light) ] )
		stringWithAttribute.addAttributes([.link: url], range: NSMakeRange(0, stringWithAttribute.string.count))
		
		// Setting attributedText hyperlink
		wikiTextView.attributedText = stringWithAttribute
		wikiTextView.isUserInteractionEnabled = true
		wikiTextView.linkTextAttributes = [
			.foregroundColor: UIColor.black,
		]
	}
}
