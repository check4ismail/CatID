//
//  Alerts.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/18/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func invalidEmail() {
		alert(title: "Invalid Email 😿", message: "Make sure your email is entered correctly")
	}
	
	func invalidPassword() {
		alert(title: "Invalid Password 😿", message: "Minimum 8 characters with at least 1 capital letter, 1 number, and 1 special character")
	}
	
	func invalidPasswordForAccount() {
		alert(title: "Invalid Password 😿", message: "Password is invalid, enter it again or tap on the 'Forgot password?' link if you forgot it")
	}
	
	func blankPassword() {
		alert(title: "Blank Password 😿", message: "Password is blank, please enter your password")
	}
	
	func successfulSignUp() {
		alert(title: "Success 😺", message: "Your sign up was a success! Go back to the sign in screen")
	}
	
	func successfulPasswordReset() {
		alert(title: "Success 😺", message: "Password reset email has been sent your way!")
	}
	
	func emailNeverRegistered() {
		alert(title: "Invalid Email 😿", message: "Email entered was never registered with CatID.")
	}
	
	func emailAlreadyRegistered() {
		alert(title: "Email Exists 😿", message: "Email entered is already registered with CatID.")
	}
	
	func errorCodeAlert(_ error: String) {
		// Displaying alerts based on error code from Firebase
		print("Firebase error: \(error)")
		if error.contains("17007") {
			emailAlreadyRegistered()
		} else if error.contains("17009") {
			invalidPasswordForAccount()
		} else if error.contains("17011") {
			emailNeverRegistered()
		}
	}
	
	private func alert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
