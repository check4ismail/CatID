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

class CatApi {

	private var breedUrlAll = "https://api.thecatapi.com/v1/breeds"
	private var breedUrl = "https://api.thecatapi.com/v1/breeds/search?q="
	private var imageUrl = "https://api.thecatapi.com/v1/images/search?breed_id="
	private let headers: HTTPHeaders = [
		"x-api-key": "d88df8ce-6c21-4cb1-9253-bb6035eec8b8"
	]
	private var breedId: String?
	private var dataUrl: String = ""
	private var catImage: UIImageView?
	
	func getCatInfo(breed catBreed: String) -> Promise<[String: Any]> {
		breedUrl += catBreed
		return Promise { seal in
			Alamofire.request(self.breedUrl, method: .get, headers: self.headers).validate().responseJSON { response in
				switch response.result {
				
				case .success(let json):
//					let json = JSON(value)
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
	
	func getAllCatIds() -> Promise<[String]> {
		return Promise { seal in
			Alamofire.request(self.breedUrlAll, method: .get, headers: self.headers).validate().responseJSON { response in
				switch response.result {
				
				case .success(let value):
					let json = JSON(value)
					var catIds: [String] = []
//					print("Count json body: \(json.count)")
					for i in 0..<json.count {
						guard let catId = json[i,"id"].string else {
							print("Could not parse cat Id at index \(i)")
							continue
						}
						catIds.append(catId)
					}
//					print("Get all catIds: \(catIds)")
					seal.fulfill(catIds)
				
				case .failure(let error):
					seal.reject(error)
				}
			}
		}
	}
	
	func getCatPhoto(_ catId: String) -> Promise<String> {
		return Promise { seal in
			let imageUrl = self.imageUrl + catId
			print("Will be requesting with this url: \(imageUrl)")
			Alamofire.request(imageUrl, method: .get, headers: headers).validate().responseJSON { response in
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
	
	func getCatPhotoUrl() -> String {
		return dataUrl
	}
	
	func getImageView() -> UIImageView? {
		return catImage ?? nil
	}

}
