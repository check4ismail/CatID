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
import PromiseKit
import Kingfisher
import CoreData

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
	
	// Stores breed selected from CatIdController
	var selectedBreed: String?
	
	private var cats: [Cat] = []
	private var catMetaData: NSManagedObject?
	
	private let bulletPoint: String = "🔵 "
	private let bulletPointEmpty = "⚪️ "
	private var breed = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.title = selectedBreed
		fetchAllCatDetails()

		let isBreedSaved: Bool = containsBreed()
		
		if let breed = selectedBreed {
			self.breed = breed
			
			if isBreedSaved { // Load meta data from core data
				getCatInfoFromDisk()
			} else {	// Load data from API request
				getCatInfo()
			}
			
			getCatPhoto()
		}
	}
	
	// Returns true if breed is stored in Core Data
	// otherwise returns false
	func containsBreed() -> Bool {
		
		for cat in cats {
			let breedValue = cat.breed
			if breedValue == title {
				catMetaData = cat
				return true
			}
		}
		
		return false
	}
	
	// Loads core data objects
	func fetchAllCatDetails() {
		guard let fetchedCats = CoreDataManager.sharedManager.fetchAllCatDetails() else {
			return
		}
		
		cats = fetchedCats
	}
	
	// Fetches temperament, ratings, description and wiki link of breed from API
	// then updates corresponding UI textfields and textviews in main thread
	func getCatInfo() {
		print("breed: \(breed)")
		CatApi.getCatBreedInfo(breed: breed)
			.done { json in
				DispatchQueue.main.async(execute: {
					print("Filling cat info - API")
					
					var jsonIndex: Int = 0
					if self.breed == "Malayan" {
						jsonIndex = 1
					}
					
					if let temperament = json[jsonIndex,"temperament"].string,
						let childFriendly = json[jsonIndex,"child_friendly"].int,
						let grooming = json[jsonIndex,"grooming"].int,
						let intelligence = json[jsonIndex,"intelligence"].int,
						let sheddingLevel = json[jsonIndex,"shedding_level"].int,
						let socialNeeds = json[jsonIndex,"social_needs"].int,
						let description = json[jsonIndex,"description"].string
					{
						self.temperament.text = temperament
						self.fillRatings([Int](arrayLiteral: childFriendly, grooming, intelligence, sheddingLevel, socialNeeds))
						self.summaryTextView.text = description
						
						self.showAllViews()
					}
					
					// Some cat breeds only have their cfa_url available
					if let wikiLink = json[jsonIndex,"wikipedia_url"].string {
						self.setWikiLink(wikiLink)
						self.save(wikiLink) // Save cat meta data to core data
					} else if let wikiLink = json[jsonIndex,"cfa_url"].string {
						self.setWikiLink(wikiLink)
						self.save(wikiLink) // Save cat meta data to core data
					}
				})
			}.catch { error in
				print("Error: \(error)")
			}
	}
	
	// Cat meta data fetched from NSManagedObject
	// with correponding UI fields being updated
	func getCatInfoFromDisk() {
		print("Filling cat info - Disk")
		
		childRatingTextField.text = catMetaData?.value(forKeyPath: "childFriendlyRating") as? String
		groomingRatingTextField.text = catMetaData?.value(forKeyPath: "groomingRating") as? String
		intelligenceRatingTextField.text = catMetaData?.value(forKeyPath: "intelligenceRating") as? String
		sheddingRatingTextField.text = catMetaData?.value(forKeyPath: "sheddingRating") as? String
		socialNeedsRatingTextField.text = catMetaData?.value(forKeyPath: "socialNeedsRating") as? String
		summaryTextView.text = catMetaData?.value(forKeyPath: "summaryText") as? String
		temperament.text = catMetaData?.value(forKeyPath: "temperament") as? String
		
		showAllViews()
		let wikiLink = catMetaData?.value(forKeyPath: "wikiLink") as! String
		setWikiLink(wikiLink)
	}
	
	func showAllViews() {
		let arrayEnableTextFields: [UITextField] = [childFriendlyTextField, groomingTextField, intelligenceTextField, sheddingTextField, socialNeedsTextField]
		arrayEnableTextFields.forEach {
			$0.isHidden = false
		}
		temperament.isHidden = false
		summaryTextView.isHidden = false
	}
	
	// MARK: Refresh button - iterates to next URL for cat breed
	@IBAction func generateNewCatPhoto(_ sender: UIBarButtonItem) {
		let catPhotos = CatBreeds.nextImageUrl(breed)
		if let newPhoto = catPhotos.1 {
			print("Filling NEW photo")
			catImage.kf.setImage(with: newPhoto, options: [.transition(.fade(0.3))])
		}
		if let oldPhoto = catPhotos.0 {
			print("Removing OLD photo from cache")
			let cache = ImageCache.default
			cache.removeImage(forKey: oldPhoto.absoluteString)
		}
	}
	
	func getCatPhoto() {
		let url = CatBreeds.defaultCatPhoto[breed]
		print("Filling cat photo")
		catImage.kf.setImage(with: url, options: [.transition(.fade(0.3))])
	}
	
	func fillRatings(_ ratingArray: [Int]) {
		let ratingTextFields: [UITextField] = [childRatingTextField, groomingRatingTextField, intelligenceRatingTextField, sheddingRatingTextField, socialNeedsRatingTextField]
		
		// Fill bullet point rating for each textfield
		for i in 0..<ratingArray.count {
			for _ in 0..<ratingArray[i] {
				if let ratingText = ratingTextFields[i].text {
					ratingTextFields[i].text = ratingText + bulletPoint
				}
			}
			let emptyBulletPointCount = 5 - ratingArray[i]
			for _ in 0..<emptyBulletPointCount {
				if let ratingText = ratingTextFields[i].text {
					ratingTextFields[i].text = ratingText + bulletPointEmpty
				}
			}
		}
	}
	
	func setWikiLink(_ wikiLink: String) {
		let url = URL(string: wikiLink)!
		
		// Setting up hyperlink, with specific font size
		
		// Printing out all available custom fonts
//		for family: String in UIFont.familyNames
//        {
//            print(family)
//            for names: String in UIFont.fontNames(forFamilyName: family)
//            {
//                print("== \(names)")
//            }
//        }
		let stringWithAttribute = NSMutableAttributedString(string: "WIKIPEDIA", attributes: [
			NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Regular" , size: 18.0)! ])
		stringWithAttribute.addAttributes([.link: url], range: NSMakeRange(0, stringWithAttribute.string.count))
		
		// Setting attributedText hyperlink
		wikiTextView.attributedText = stringWithAttribute
		wikiTextView.isUserInteractionEnabled = true
	}
	
	// Saving cat meta data from API request to Core Data
	func save(_ wikiLink: String) {
	  
		let imageUrl = CatBreeds.defaultCatPhoto[breed]?.absoluteString
		CatDetailedData.data.setData(wikiLink,
									 temperament.text,
									 summaryTextView.text,
									 socialNeedsRatingTextField.text,
									 sheddingRatingTextField.text,
									 intelligenceRatingTextField.text,
									 imageUrl,
									 groomingRatingTextField.text,
									 childRatingTextField.text,
									 breed)
		
		CoreDataManager.sharedManager.insertCatDetailedData()
	}
}
