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
		static var value: String = ProcessInfo.processInfo.environment["CAT_API_KEY"]!
	}
}
