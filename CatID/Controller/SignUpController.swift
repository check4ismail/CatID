//
//  SignUpController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/2/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
	
	@IBOutlet weak var emailTextInput: UITextField!
	@IBOutlet weak var passwordTextInput: UITextField!
	
	@IBAction func backToLogin(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func attemptSignUp(_ sender: UIButton) {
		
		self.showIndicator()
		
		guard SignInRules.emailRules(email: emailTextInput.text!) else {
			self.hideIndicator()
			
			invalidEmail()
			return
		}
		
		guard SignInRules.passwordRules(password: passwordTextInput.text!) else {
			self.hideIndicator()
			
			invalidPassword()
			return
		}
		
		Auth.auth().createUser(withEmail: emailTextInput.text!, password: passwordTextInput.text!) { authResult, error in
			if let errorMessage = error, !errorMessage.localizedDescription.isEmpty {
				
				self.hideIndicator()
				
				self.errorCodeAlert("\(errorMessage)")
				return
			}
			
			self.hideIndicator()
			
			// If no errors, sign up is a success!
			self.successfulSignUp()
		}
		
	}
}
