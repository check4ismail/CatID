//
//  SignInRules.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/18/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import Foundation

struct SignInRules {
	private static let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
	private static let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
	
	static func emailRules(email: String) -> Bool {
		return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
	}
	
	static func passwordRules(password: String) -> Bool {
		return NSPredicate(format:"SELF MATCHES %@", passwordRegEx).evaluate(with: password)
	}
}
