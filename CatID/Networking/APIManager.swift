//
//  APIManager.swift
//  CatID
//
//  Created by Ismail Elmaliki on 10/31/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import Foundation
import Alamofire

struct APIManager {
	
	struct APIKey {
		static let header = "x-api-key"
		// Utilizing env variable for key value
		static var value: String = "d88df8ce-6c21-4cb1-9253-bb6035eec8b8"
	}
}
