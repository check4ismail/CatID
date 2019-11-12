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
	
	private var cats: [NSManagedObject] = []
	private var catMetaData: NSManagedObject?
	
	private let bulletPoint: String = "🔵 "
	private var breed = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.title = selectedBreed
		load()
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
			let breedValue = cat.value(forKey: "breed") as! String
			if breedValue == title {
				catMetaData = cat
				return true
			}
		}
		
		return false
	}
	
	// Loads core data objects
	func load() {
		//1
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		
		let managedContext = appDelegate.persistentContainer.viewContext
		
		//2
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cat")
		
		//3
		do {
			cats = try managedContext.fetch(fetchRequest)
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
	}
	
	// Fetches temperament, ratings, description and wiki link of breed from API
	// then updates corresponding UI textfields and textviews in main thread
	func getCatInfo() {
		print("breed: \(breed)")
		CatApi.getCatBreedInfo(breed: breed)
			.done { json in
				DispatchQueue.main.async(execute: {
					print("Filling cat info - API")
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
						
						self.showAllViews()
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
		arrayEnableTextFields.forEach { $0.isHidden = false }
		temperament.isHidden = false
		summaryTextView.isHidden = false
	}
	
	func getCatPhoto() {
		let url = CatBreeds.imageUrls[breed]
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
	
	// Saving cat meta data from API request to Core Data
	func save(_ wikiLink: String) {
	  
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	  
		// 1
		let managedContext = appDelegate.persistentContainer.viewContext
	  
		// 2
		let entity = NSEntityDescription.entity(forEntityName: "Cat", in: managedContext)!
	  
		let cat = NSManagedObject(entity: entity, insertInto: managedContext)
	  
		let imageUrl = CatBreeds.imageUrls[breed]?.absoluteString
		// 3
		cat.setValue(breed, forKeyPath: "breed")
		cat.setValue(imageUrl, forKeyPath: "imageUrl")
		cat.setValue(childRatingTextField.text, forKeyPath: "childFriendlyRating")
		cat.setValue(groomingRatingTextField.text, forKeyPath: "groomingRating")
		cat.setValue(intelligenceRatingTextField.text, forKeyPath: "intelligenceRating")
		cat.setValue(sheddingRatingTextField.text, forKeyPath: "sheddingRating")
		cat.setValue(socialNeedsRatingTextField.text, forKeyPath: "socialNeedsRating")
		cat.setValue(summaryTextView.text, forKeyPath: "summaryText")
		cat.setValue(temperament.text, forKeyPath: "temperament")
		cat.setValue(wikiLink, forKeyPath: "wikiLink")
	  
		// 4
		do {
			try managedContext.save()
			cats.append(cat)
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
}
