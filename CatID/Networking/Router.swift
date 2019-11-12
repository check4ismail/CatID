//
//  Router.swift
//  CatID
//
//  Created by Ismail Elmaliki on 10/31/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {
	
	case readCatInfo(breed: String)
	case readCatPhoto(breedId: String)
	
	static let baseURLString = "https://api.thecatapi.com/v1"
	
	var method: HTTPMethod {
		switch self {
		case .readCatInfo:
			return .get
		case .readCatPhoto:
			return .get
		}
	}
	
	// Different paths for API call
	var path: String {
		switch self {
		case .readCatInfo(let breed):
			return "/breeds/search?q=\(breed)"
		case .readCatPhoto(let breedId):
			return "/images/search?breed_id=\(breedId)"
		}
	}
	
	// Returns complete URL request, including http method and
	// required headers
	func asURLRequest() throws -> URLRequest {
		let url = try Router.baseURLString.asURL()
		var urlRequest: URLRequest?
		if let completeUrl = URL(string: "\(url)\(path)") {
			urlRequest = URLRequest(url: completeUrl)
		}

        urlRequest?.httpMethod = method.rawValue
		urlRequest?.setValue(APIManager.APIKey.value, forHTTPHeaderField: APIManager.APIKey.header)
		
        return urlRequest!
	}
}
