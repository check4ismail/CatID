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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		tableView.reloadData()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		performSegue(withIdentifier: "goToCatBreed", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! CatBreedController
		
		if let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedBreed = catBreeds[indexPath.row]
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catBreeds.count
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
		cell.textLabel?.text = catBreeds[indexPath.row]
		
		return cell
	}

}

