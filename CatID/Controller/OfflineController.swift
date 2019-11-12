//
//  OfflineController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 11/9/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit

class OfflineController: UIViewController {
	
	var timer: Timer?
	var timeCounter: Int = 1
	
	override func viewDidAppear(_ animated: Bool) {
		print("Offline has been displayed")
		
		// Runs function runTimedCode every 10 seconds
		timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		print("Going back!")
		timer?.invalidate()
	}
	
	@objc
	func runTimedCode() {
		print("Running timed code, iteration \(timeCounter) - OfflineController")
		timeCounter += 1
		
		// Goes back to CatIdController if online
		if Connectivity.isConnectedToInternet {
			self.dismiss(animated: true)
		}
	}
}
