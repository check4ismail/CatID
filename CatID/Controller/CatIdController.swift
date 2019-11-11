//
//  ViewController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/26/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import AlamofireImage
import Kingfisher

class CatIdController: UIViewController {

	// Outlets
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	// Members
	private let catBreeds: [String] = CatBreeds.breeds
	private var realmBreedData = [String: [Breed]]()
	private var catSectionTitles = [String]()
	private var catBreedDictionary = [String: [String]]()
	private var searchActive: Bool = false
	private var filtered:[String] = []
	var timer: Timer?
	var timeCounter: Int = 1
	
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
	
	override func viewDidAppear(_ animated: Bool) {
		timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
	}
	
	@objc
	func runTimedCode() {
		print("Running timed code, iteration \(timeCounter) - CatIdController")
		timeCounter += 1
		if !Connectivity.isConnectedToInternet {
			performSegue(withIdentifier: "offline", sender: self)
			timer?.invalidate()
		}
	}
	
//	private func loadImagesInBackground() {
//		DispatchQueue.global(qos: .background).async { [weak self] in
//			print("Starting background task to check internet connection")
//
//			performSegue(withIdentifier: "offline", sender: self)
//			guard let self = self else {
//				return
//			}
//			var imageUrls: [URL] = []
//			for breed in self.catBreeds {
//				if let breedId = CatBreeds.breedIds[breed] {
//					CatApi.getCatPhoto(breedId)
//					.done{ url in
//						guard let url = URL(string: url) else { return }
//						CatBreeds.imageUrls[breed] = url
//						imageUrls.append(url)
//						if imageUrls.count == self.catBreeds.count {
//							print("All images cached in background")
//							ImagePrefetcher(urls: imageUrls).start()
//						}
//					  }.catch { error in
//							print("Error: \(error)")
//					  }
//				}
//			}
//		}
//	}
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
	
//	private func setRealmBreedData() {
//		let realm = try! Realm()
//		let breeds = realm.objects(Breed.self)
//
//		for breed in breeds {
//			let breedName = breed.breedName
//			let breedKey = String(breedName.prefix(1)) // First letter of string
//
//			if var breedValues = realmBreedData[breedKey] {
//				breedValues.append(breed)
//				realmBreedData[breedKey] = breedValues
//			} else {
//				realmBreedData[breedKey] = [breed]
//			}
//		}
//
//		dump(realmBreedData)
//	}
	
	override func viewWillAppear(_ animated: Bool) {
		if let index = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: index, animated: true)
		}
		tableView.reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		timer?.invalidate()
	}
	
	//MARK: Prepare segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard Connectivity.isConnectedToInternet else { return }
		let destinationVC = segue.destination as! CatBreedController
		
		if let indexPath = self.tableView.indexPathForSelectedRow {
			if searchActive {
				// Pass cell that was selected from search
				let currentCell = tableView.cellForRow(at: indexPath)
				let text = String((currentCell?.textLabel!.text)!)
				print("current cell from search: \(text)")
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
		if !Connectivity.isConnectedToInternet {
			performSegue(withIdentifier: "offline", sender: self)
		} else {
			performSegue(withIdentifier: "goToCatBreed", sender: self)
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CatTableViewCell
		
		searchActive = isSearchBarEmpty() // Safeguard for empty search when search is cleared
		if searchActive {
			cell.catBreed?.text?.removeAll()
			print("Current row: \(indexPath.row)")
			cell.textLabel?.text = filtered[indexPath.row]
		} else {
			let catKey = catSectionTitles[indexPath.section]
			if let catValues = catBreedDictionary[catKey] {
				let breed = catValues[indexPath.row]
				cell.textLabel?.text?.removeAll()
				guard Connectivity.isConnectedToInternet else {
					cell.textLabel?.text = breed
					return cell
				}
				guard let breedId = CatBreeds.breedIds[breed] else { return cell }
				cell.catBreed?.text = catValues[indexPath.row]
				cell.catBreed?.textColor = UIColor.black
				tableView.rowHeight = 85
				if let imageUrl = CatBreeds.imageUrls[breed] {
//					print("Display cat image \(breed) from memory")
					cell.setCustomImage(url: imageUrl, width: 75, height: 75)
				} else { // If photo isn't cached in memory
					CatApi.getCatPhoto(breedId)
						.done{ url in
							guard let url = URL(string: url) else { return }
							CatBreeds.imageUrls[breed] = url
//							print("Setting image for \(breed)")
							cell.setCustomImage(url: url, width: 75, height: 75)
						}.catch { error in
							print("Error: \(error)")
						}
				}
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.imageView?.kf.cancelDownloadTask()
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
