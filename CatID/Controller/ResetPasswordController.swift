//
//  ResetPasswordController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/17/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordController: UIViewController {
	@IBOutlet weak var emailTextInput: UITextField!
	
	@IBAction func backToLogin(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func resetPassword(_ sender: UIButton) {
		
		self.showIndicator()
		
		guard SignInRules.emailRules(email: emailTextInput.text!) else {
			self.hideIndicator()
			
			invalidEmail()
			return
		}
		
		Auth.auth().sendPasswordReset(withEmail: emailTextInput.text!) { error in
			if let errorMessage = error, !errorMessage.localizedDescription.isEmpty {
				self.hideIndicator()
				
				self.errorCodeAlert("\(errorMessage)")
				return
			}
			
			self.hideIndicator()
			
			// If no errors, password successfully reset
			self.successfulPasswordReset()
		}
	}
}
