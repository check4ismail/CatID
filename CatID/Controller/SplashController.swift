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
		Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
			timer.invalidate()
			self.performSegue(withIdentifier: self.segueCatId, sender: self)
		}
	}
	
}
