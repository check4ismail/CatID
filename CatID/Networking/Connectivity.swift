//
//  Connectivity.swift
//  CatID
//
//  Created by Ismail Elmaliki on 10/14/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
	
	// Determines if device is online or offline
	class var isConnectedToInternet: Bool {
		return NetworkReachabilityManager()!.isReachable
	}
}
