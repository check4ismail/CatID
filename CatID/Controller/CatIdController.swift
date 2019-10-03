//
//  ViewController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/26/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit

class CatIdController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

	// Outlets	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	// Members
	private let catBreeds: [String] = CatBreeds().getBreeds()
	private var catSectionTitles = [String]()
	private var catBreedDictionary = [String: [String]]()
	private var searchActive: Bool = false
	var filtered:[String] = []
	
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
		
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.reloadData()
	}

	//MARK: Segue to Cat Breed Controller
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
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
	func numberOfSections(in tableView: UITableView) -> Int {
		if searchActive {
			return 1
		} else {
			return catSectionTitles.count
		}
	}
	
	// Number of rows in each indexed section
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
		if searchActive {
			return filtered.count
		} else {
			let catKey = catSectionTitles[section]
			if let catValues = catBreedDictionary[catKey] {
				return catValues.count
			}
		}
			
		return 0
    }
	
	// Populating each row in each section
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
		
		if searchActive {
			cell.textLabel?.text = filtered[indexPath.row]
			print(cell)
		} else {
			let catKey = catSectionTitles[indexPath.section]
			if let catValues = catBreedDictionary[catKey] {
				cell.textLabel?.text = catValues[indexPath.row]
			}
		}
		
		return cell
	}
	
	// Display header title
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if searchActive {
			return nil
		}
		return catSectionTitles[section]
	}
	
	// Indexed table view displayed
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		if searchActive {
			return nil
		}
		return catSectionTitles
	}
	
	//MARK: search bar functions
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchActive = true
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchActive = false
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filtered = catBreeds.filter({ (text) -> Bool in
			let tmp: NSString = NSString(string: text)
			let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
		})
		if(filtered.count == 0){
			isSearchBarEmpty()
        } else {
            searchActive = true;
        }
		
        tableView.reloadData()
	}
	
	func isSearchBarEmpty() {
		if searchBar.text != "" {
			searchActive = true
		} else {
			searchActive = false
		}
	}
}

