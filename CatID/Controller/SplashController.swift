//
//  SplashController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 12/14/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit

class SplashController: UIViewController {
	
	private let segueCatId = "showCatId"
	override func viewDidLoad() {
		Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
			print("Splash screen timer invalidated")
			timer.invalidate()
			self.performSegue(withIdentifier: self.segueCatId, sender: self)
		}
	}
	
}
