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

	static func getCatBreedInfo(breed catBreed: String) -> Promise<[String: Any]> {
		let breed = catBreed.replacingOccurrences(of: " ", with: "_")
		return Promise { seal in
			Alamofire.request(Router.readCatInfo(breed: breed)).validate().responseJSON { response in
				switch response.result {
				
				case .success(let json):
//					print()
					guard let json = json  as? [String: Any] else {
					   return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
					}
				   seal.fulfill(json)
				
				case .failure(let error):
					seal.reject(error)
				}
			}
		}
	}
	
	static func getCatPhoto(_ catId: String) -> Promise<String> {
		return Promise { seal in
			Alamofire.request(Router.readCatPhoto(breedId: catId)).validate().responseJSON { response in
					switch response.result {
					
					case .success(let value):
						let json = JSON(value)
						guard let imageUrl = json[0,"url"].string else {
							return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
						 }
						seal.fulfill(imageUrl)
					case .failure(let error):
						seal.reject(error)
					}
			}
		}
	}
}
