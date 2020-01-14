//
//  LoginController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/1/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
	
	@IBOutlet weak var signUpButton: UIButton!
	
	let segue = "signUpSegue"
	
	override func viewDidLoad() {
		loadSignUp()
	}
	
	private func loadSignUp() {
		let newUserText = "New user?"
		let signUpText = " Signup"
		
		let userAttribute = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Regular", size: 22.0)!,
							  NSAttributedString.Key.foregroundColor: UIColor.black]
		let signUpAttribute = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Semibold", size: 22.0)!,
		NSAttributedString.Key.foregroundColor: UIColor.black]
		
		let attributedString = NSMutableAttributedString(string: newUserText, attributes: userAttribute)
		attributedString.append(NSMutableAttributedString(string: signUpText, attributes: signUpAttribute))
		
		signUpButton.setAttributedTitle(attributedString, for: .normal)
	}
	
	@IBAction func attemptLogin(_ sender: UIButton) {
		print("Touched button")
	}
	
	@IBAction func signUpFlow(_ sender: UIButton) {
		performSegue(withIdentifier: segue, sender: self)
	}
	
	
}
