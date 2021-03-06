//
//  CatApi.swift
//  CatID
//
//  Created by Ismail Elmaliki on 10/19/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import SwiftyJSON
import Alamofire
import AlamofireImage
import PromiseKit

public struct CatApi {

	// API request for cat meta data, returns JSON
	static func getCatBreedInfo(breed catBreed: String) -> Promise<JSON> {
		let breed = catBreed.replacingOccurrences(of: " ", with: "_")
		return Promise { seal in
			Alamofire.request(Router.readCatInfo(breed: breed)).validate().responseJSON { response in
				switch response.result {
				
				case .success(let json):
					let json = JSON(json)
					seal.fulfill(json)
				
				case .failure(let error):
					seal.reject(error)
				}
			}
		}
	}
	
	// API request for cat image url, returns url in String format
//	static func getCatPhoto(_ catId: String) -> Promise<String> {
	static func getCatPhoto(_ catId: String) -> Promise<[String]> {
		return Promise { seal in
			Alamofire.request(Router.readCatPhoto(breedId: catId)).validate().responseJSON { response in
					switch response.result {
					
					case .success(let value):
						let json = JSON(value)
						var imageUrls: [String] = []
						for i in 0..<json.count {
							guard let imageUrl = json[i,"url"].string else {
							   return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
							}
							imageUrls.append(imageUrl)
						}
						seal.fulfill(imageUrls)
					case .failure(let error):
						seal.reject(error)
					}
			}
		}
	}
}
