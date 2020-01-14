//
//  SignUpController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/2/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Firebase

public class SignUpController: UIViewController {
	
	@IBOutlet weak var emailTextInput: UITextField!
	@IBOutlet weak var passwordTextInput: UITextField!
	
	@IBAction func backToLogin(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	private func emailRules() -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: emailTextInput.text)
	}
	
	private func passwordRules() -> Bool {
		let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
		return NSPredicate(format:"SELF MATCHES %@", passwordRegEx).evaluate(with: passwordTextInput.text)
	}
	
	@IBAction func attemptSignUp(_ sender: UIButton) {
		guard emailRules() else {
			alert(title: "Invalid Email 😿", message: "Make sure your email is entered correctly")
			return
		}
		
		guard passwordRules() else {
			alert(title: "Invalid Password 😿", message: "Minimum 8 characters with at least 1 capital letter, 1 number, and 1 special character")
			return
		}
		
		Auth.auth().createUser(withEmail: emailTextInput.text!, password: passwordTextInput.text!) { authResult, error in
			if let _ = authResult?.additionalUserInfo?.isNewUser {
				self.alert(title: "Success 😺", message: "Your sign up was a success! Go back to the sign in screen")
			} else {
				print("Error: \(error)")
			}
			
		}
		
	}
	
	private func alert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	
}
