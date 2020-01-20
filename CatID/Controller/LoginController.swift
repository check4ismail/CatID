//
//  LoginController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/1/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginController: UIViewController {
	
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var paswordTextInput: UITextField!
	@IBOutlet weak var emailTextInput: UITextField!
	
	let segue = "signUpSegue"
	let resetPasswordSegue = "resetPassword"
	let catIdSegue = "showCatId"
	
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
		guard SignInRules.emailRules(email: emailTextInput.text!) else {
			invalidEmail()
			return
		}
		
		guard paswordTextInput.text!.count > 0 else {
			blankPassword()
			return
		}
		
		Auth.auth().signIn(withEmail: emailTextInput.text!, password: paswordTextInput.text!) { [weak self] authResult, error in
			self!.showIndicator()
			if let errorMessage = error, !errorMessage.localizedDescription.isEmpty {
				self!.hideIndicator()
				self!.errorCodeAlert("\(errorMessage)")
				return
			}
			// Method to retrieve all cat photos
			CatBreeds.retrieveCatPhotos()
			Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
				if CatBreeds.photosRetrieved {
					print("Photos retrieved? \(CatBreeds.photosRetrieved)")
					timer.invalidate()
					self!.hideIndicator()
					self?.performSegue(withIdentifier: "catIdApp", sender: self)
				}
			}
		}
	}
	
	@IBAction func signUpFlow(_ sender: UIButton) {
		performSegue(withIdentifier: segue, sender: self)
	}
	
	@IBAction func resetPassword(_ sender: UIButton) {
		performSegue(withIdentifier: resetPasswordSegue, sender: self)
	}
	
}

extension UIViewController {
	func showIndicator() {
		DispatchQueue.main.async {
			SVProgressHUD.show()
//			Utility.showLoaderWithText(text: "Authenticating")
		}
	}
	
	func hideIndicator() {
		DispatchQueue.main.async {
			SVProgressHUD.dismiss()
//			Utility.hideLoader()
		}
	}
}
