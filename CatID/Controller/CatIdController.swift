//
//  ViewController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/26/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit
import RealmSwift

class CatIdController: UIViewController {

	// Outlets
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	// Members
	private let catBreeds: [String] = CatBreeds().getBreeds()
	private var realmBreedData = [String: [Breed]]()
	private var catSectionTitles = [String]()
	private var catBreedDictionary = [String: [String]]()
	private var searchActive: Bool = false
	private var filtered:[String] = []

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
	}
	
//	override func viewDidAppear(_ animated: Bool) {
//		navigationController?.navigationBar.barStyle = .white
//	}
//
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "58cced")
		
		let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = .black
		
		//MARK: Tap outside of search bar to dismiss keyboard without overriding tableview touch
		let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
		
		setCatDictionary()
		setRealmBreedData()
		
		searchBar.delegate = self
		searchBar.showsCancelButton = true
		view.addSubview(searchBar)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.reloadData()
		
		// Does not override touch for ui elements in view
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	private func setCatDictionary() {
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
	}
	
	private func setRealmBreedData() {
		let realm = try! Realm()
		let breeds = realm.objects(Breed.self)
		
		for breed in breeds {
			let breedName = breed.breedName
			let breedKey = String(breedName.prefix(1)) // First letter of string
			
			if var breedValues = realmBreedData[breedKey] {
				breedValues.append(breed)
				realmBreedData[breedKey] = breedValues
			} else {
				realmBreedData[breedKey] = [breed]
			}
		}
		dump(realmBreedData)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if let index = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: index, animated: true)
		}
	}
	
	//MARK: Prepare segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! CatBreedController
		
		if let indexPath = self.tableView.indexPathForSelectedRow {
			if searchActive {
				// Pass cell that was selected from search
				let currentCell = tableView.cellForRow(at: indexPath)
				destinationVC.selectedBreed = currentCell?.textLabel?.text
			} else {
				// Pass cell from ordered dictionary
				let catKey = catSectionTitles[indexPath.section]
				if let catValues = catBreedDictionary[catKey] {
					destinationVC.selectedBreed = catValues[indexPath.row]
				}
			}
		}
	}
}

extension CatIdController: UITableViewDelegate, UITableViewDataSource {
	//MARK: TableView methods
	
	// Segue based on row selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToCatBreed", sender: self)
	}
	
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
		tableView.rowHeight = 70
		let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
		searchActive = isSearchBarEmpty() // Safeguard for empty search when search is cleared
		if searchActive {
			cell.textLabel?.text = filtered[indexPath.row]
		} else {
			let catKey = catSectionTitles[indexPath.section]
			if let catValues = catBreedDictionary[catKey], let breedUrls = realmBreedData[catKey] {
				cell.textLabel?.text = catValues[indexPath.row]
				cell.textLabel?.textColor = UIColor.black
				
				// Image in cell
				print("Breed from Realm: \(breedUrls[indexPath.row].breedName)")
				print("URL from Realm: \(breedUrls[indexPath.row].url)")
				guard let url = URL(string: breedUrls[indexPath.row].url) else { return cell }
				guard let imageOfCell = cell.imageView else { return cell }
				
				
				imageOfCell.af_setImage(withURL: url)

				let itemSize:CGSize = CGSize(width: 75, height: 75)
				UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
				imageOfCell.image?.draw(in: CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height))
				imageOfCell.image = UIGraphicsGetImageFromCurrentImageContext()
				UIGraphicsEndImageContext()

				imageOfCell.contentMode = UIView.ContentMode.scaleAspectFill
				imageOfCell.layer.masksToBounds = false
				imageOfCell.layer.borderWidth = 1.0
				imageOfCell.layer.cornerRadius = imageOfCell.frame.size.height/2
				imageOfCell.clipsToBounds = true
					
//				}
				
//				if let url = breed?.url {
//					if let imageOfCell = cell.imageView {
//						imageOfCell.af_setImage(withURL: breed?.url)
//
//						let itemSize:CGSize = CGSize(width: 100, height: 100)
//						UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
//						imageOfCell.image?.draw(in: CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height))
//						cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
//						UIGraphicsEndImageContext()
//
//						imageOfCell.contentMode = UIView.ContentMode.scaleAspectFit
//						imageOfCell.layer.masksToBounds = false
//						imageOfCell.layer.borderWidth = 1.0
//						imageOfCell.layer.cornerRadius = imageOfCell.frame.size.height/2
//						imageOfCell.clipsToBounds = true
//					}
//				}
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
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = UIColor(hexString: "7bd7f1")
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = UIColor.black
	}
}

extension CatIdController: UISearchBarDelegate {
	//MARK: search bar functions
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchActive = true
	}
	
	// Touch outside search bar calls this method
	// triggering isSearchBarEmpty() to ensure correct searchActive status
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchActive = isSearchBarEmpty()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchActive = true
		searchBar.endEditing(true)	// Dismiss keyboard
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false
		searchBar.endEditing(true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filtered = catBreeds.filter({ (text) -> Bool in
			let tmp: NSString = NSString(string: text)
			let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
		})
		if(filtered.count == 0){
			searchActive = isSearchBarEmpty()
        } else {
            searchActive = true;
        }
		
        tableView.reloadData()
	}
	
	func isSearchBarEmpty() -> Bool {
		if searchBar.text != "" {
			return true
		} else {
			return false
		}
	}
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
