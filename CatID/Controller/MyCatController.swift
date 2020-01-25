//
//  MyCatController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/22/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

class MyCatController: UIViewController, UITabBarDelegate {
	
	@IBOutlet weak var tabBar: UITabBar!
	@IBOutlet weak var myCatTableView: UITableView!
	
	private let segueToBreedList = "catBreedSegue"
	private let myCatTag = 0
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
	}
	
	override func viewDidLoad() {
		tabBar.delegate = self
		highlightTagItem(myCatTag, tabBar)
		
		setupNavigationBar()
		
//		myCatTableView.delegate = self
//		myCatTableView.dataSource = self
//		myCatTableView.reloadData()
	}
	
	func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		let tabBarItemTag = item.tag
		switch tabBarItemTag {
		case 1:
			performSegue(withIdentifier: segueToBreedList, sender: self)
		case 2:
			print("Working on it")
		default:
			print("Nothing happens because it's the same tag")
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		highlightTagItem(myCatTag, tabBar)
	}
}

//extension MyCatController: UITableViewDelegate, UITableViewDataSource {
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		<#code#>
//	}
//
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		<#code#>
//	}
//
//
//}
extension UIViewController {
	// Sets up default color and text for Navigation Bar
	func setupNavigationBar() {
		navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "58cced")
		
		let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font: UIFont(name: "SFProRounded-Semibold", size: 20)!]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = .black
	}
	
	func highlightTagItem(_ tag: Int, _ tabBar: UITabBar) {
		tabBar.selectedItem = tabBar.items![tag] as UITabBarItem
	}
}
