//
//  ViewController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/26/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Kingfisher

class CatIdController: UIViewController {

	// Outlets
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	// Members
	private let catBreeds: [String] = CatBreeds.breeds
	private var catSectionTitles = [String]()
	private var catBreedDictionary = [String: [String]]()
	private var searchActive: Bool = false
	private var filtered:[String] = []
	private let customCell = "customCell"
	private let segueOffline = "offline"
	private let segueCatBreed = "goToCatBreed"
	private let colorHex = "7bd7f1"
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "58cced")
		
		let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font: UIFont(name: "SFProRounded-Semibold", size: 20)!]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = .black
		
		//MARK: Tap outside of search bar to dismiss keyboard without overriding tableview touch
		let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
		
		setCatDictionary()
		
		searchBar.delegate = self
		searchBar.showsCancelButton = true
		view.addSubview(searchBar)
		
		tableView.prefetchDataSource = self
		tableView.delegate = self
		tableView.dataSource = self
		tableView.reloadData()
		
		// Does not override touch for ui elements in view
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	private func setCatDictionary() {	// Create dictionary of cat breeds organized alphabetically
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
	
	override func viewWillAppear(_ animated: Bool) {
		if let index = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: index, animated: true)
		}
		tableView.reloadData()
	}
	
	//MARK: Prepare segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard Connectivity.isConnectedToInternet else { return }
		let destinationVC = segue.destination as! CatBreedController
		
		if let indexPath = self.tableView.indexPathForSelectedRow {
			if searchActive {
				// Pass cell that was selected from search
//				let currentCell = tableView.cellForRow(at: indexPath) as! CatTableViewCell
				destinationVC.selectedBreed = passingCellForSegue(indexPath)
			} else {
				// Pass cell from ordered dictionary
				let catKey = catSectionTitles[indexPath.section]
				if let catValues = catBreedDictionary[catKey] {
					destinationVC.selectedBreed = catValues[indexPath.row]
				}
			}
		}
	}
	
	private func passingCellForSegue(_ indexPath: IndexPath) -> String {
		if !Connectivity.isConnectedToInternet {
			let currentCell = tableView.cellForRow(at: indexPath)
			return (currentCell?.textLabel!.text)!
		}
		
		let currentCell = tableView.cellForRow(at: indexPath) as! CatTableViewCell
		return currentCell.catBreed.text!
	}
}

//extension CatIdController: UITableViewDelegate, UITableViewDataSource {
extension CatIdController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
	
	// MARK: Prefetching table cells
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		if !searchActive {
			indexPaths.forEach { index in
				var cell = customCell(at: index)
				let catKey = catSectionTitles[index.section]
				if let catValues = catBreedDictionary[catKey] {
					let breed = catValues[index.row]
					
					// Without internet connection, use default textLabel
					guard Connectivity.isConnectedToInternet else {
						cell = displayOfflineCatCell(cell, index, breed)
						return
					}
					
					// Get full cat cell
					cell = displayOnlineCatCell(cell, index, breed)
				}
			}
		}
	}

	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		if !searchActive {
			indexPaths.forEach { index in
				let cell = customCell(at: index)
				cell.catBreedPhoto.kf.cancelDownloadTask()
			}
		}
	}
	
	
	//MARK: TableView methods
	
	// Segue based on row selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if !Connectivity.isConnectedToInternet {
			performSegue(withIdentifier: segueOffline, sender: self)
		} else {
			performSegue(withIdentifier: segueCatBreed, sender: self)
		}
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
		tableView.rowHeight = 85
		let cell = customCell(at: indexPath)
		if !CatBreeds.photosRetrieved && Connectivity.isConnectedToInternet {
			CatBreeds.retrieveCatPhotos()
			print("Current value: \(CatBreeds.photosRetrieved)")
		}
		
		searchActive = isSearchBarEmpty() // Safeguard for empty search when search is cleared
		if searchActive { // Displays search using default textLabel from cell
			cell.catBreed?.text?.removeAll()
			if !Connectivity.isConnectedToInternet {
				return displayOfflineCatCell(cell, indexPath, filtered[indexPath.row])
			}
//			cell.textLabel?.text = filtered[indexPath.row]
			return displayOnlineCatCell(cell, indexPath, filtered[indexPath.row])
		} else {
			let catKey = catSectionTitles[indexPath.section]
			if let catValues = catBreedDictionary[catKey] {
				let breed = catValues[indexPath.row]
				
				// Without internet connection, use default textLabel
				guard Connectivity.isConnectedToInternet else {
					return displayOfflineCatCell(cell, indexPath, breed)
				}
				
				// Get full cat cell
				return displayOnlineCatCell(cell, indexPath, breed)
			}
		}
		
		return cell
	}
	
	private func displayOnlineCatCell(_ cell: CatTableViewCell, _ indexPath: IndexPath, _ breed: String) -> CatTableViewCell {
		// Filling custom cell textLabel and UIImage
		cell.textLabel?.text?.removeAll()
		guard let breedId = CatBreeds.breedIds[breed] else { return cell }
		cell.catBreed?.text = breed
		cell.catBreed?.textColor = UIColor.black
		
		if let imageUrl: URL = CatBreeds.defaultCatPhoto[breed] {
			// Loading imageUrl from memory
			cell.setCustomImage(url: imageUrl, width: 100, height: 100)
		} else { // API request to get image url for cat breed
			CatApi.getCatPhoto(breedId)
				.done{ urls in
					guard let url = URL(string: urls[0]) else { return }
					if !(CatBreeds.imageUrls[breed]?.contains(url) ?? false) {
						CatBreeds.imageUrls[breed]?.append(url)
					}
					cell.setCustomImage(url: url, width: 100, height: 100)
				}.catch { error in
					print("Error: \(error)")
				}
		}
		
		return cell
	}
	
	private func displayOfflineCatCell(_ cell: CatTableViewCell, _ indexPath: IndexPath, _ breed: String) -> CatTableViewCell {
		cell.catBreed.text?.removeAll()
		cell.textLabel?.text = breed
		return cell
	}
	
	private func customCell(at indexPath: IndexPath) -> CatTableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: customCell, for: indexPath) as! CatTableViewCell
	}
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = customCell(at: indexPath)
		cell.catBreedPhoto.kf.cancelDownloadTask()
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
		view.tintColor = UIColor(hexString: colorHex)
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
		searchActive = isSearchBarEmpty()
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
        var int = UInt64()
		Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
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
