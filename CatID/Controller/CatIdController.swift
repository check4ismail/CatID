//
//  ViewController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/26/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit

class CatIdController: UITableViewController {

	// Outlets
	@IBOutlet weak var catBreedText: UITextField!
	
	// Members
	private let catBreeds: [String] = CatBreeds().getBreeds()
	private var catSectionTitles = [String]()
	private var catBreedDictionary = [String: [String]]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		for cat in catBreeds {
			let catKey = String(cat.prefix(1)) // First letter of string
			
			if var catValues = catBreedDictionary[catKey] {
				// if key has been stored, will append value to same key
				catValues.append(cat)
				catBreedDictionary[catKey] = catValues
			} else {
				// else will create new entry for key
				catBreedDictionary[catKey] = [cat]
			}
		}
		
		catSectionTitles = [String](catBreedDictionary.keys)
		catSectionTitles = catSectionTitles.sorted(by: { $0 < $1 })
		tableView.reloadData()
	}

	//MARK: Segue to Cat Breed Controller
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		performSegue(withIdentifier: "goToCatBreed", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! CatBreedController
		
		if let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedBreed = catBreeds[indexPath.row]
		}
	}
	
	//MARK: TableView methods
	
	// Number of sections
	override func numberOfSections(in tableView: UITableView) -> Int {
		return catSectionTitles.count
	}
	
	// Number of rows in each indexed section
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let catKey = catSectionTitles[section]
		if let catValues = catBreedDictionary[catKey] {
			return catValues.count
		}
			
		return 0
    }
	
	// Populating each row in each section
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
		
		let catKey = catSectionTitles[indexPath.section]
		if let catValues = catBreedDictionary[catKey] {
			cell.textLabel?.text = catValues[indexPath.row]
		}
		
		return cell
	}
	
	// Display header title
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return catSectionTitles[section]
	}
	
	// Indexed table view displayed
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return catSectionTitles
	}
}

