//
//  CatIDTests.swift
//  CatIDTests
//
//  Created by Ismail Elmaliki on 11/14/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import XCTest
import os.log
import SwiftyJSON
@testable import CatID

class CatIDTests: XCTestCase {

	let breeds = [
		"Abyssinian",
		"Aegean",
		"American Bobtail",
		"American Curl",
		"American Shorthair",
		"American Wirehair",
		"Arabian Mau",
		"Australian Mist",
		"Balinese",
		"Bambino",
		"Bengal",
		"Birman",
		"Bombay",
		"British Longhair",
		"British Shorthair",
		"Burmese",
		"Burmilla",
		"California Spangled",
		"Chantilly-Tiffany",
		"Chartreux",
		"Chausie",
		"Cheetoh",
		"Colorpoint Shorthair",
		"Cornish Rex",
		"Cymric",
		"Cyprus",
		"Devon Rex",
		"Donskoy",
		"Dragon Li",
		"Egyptian Mau",
		"European Burmese",
		"Exotic Shorthair",
		"Havana Brown",
		"Himalayan",
		"Japanese Bobtail",
		"Javanese",
		"Khao Manee",
		"Korat",
		"Kurilian",
		"LaPerm",
		"Maine Coon",
		"Malayan",
		"Manx",
		"Munchkin",
		"Nebelung",
		"Norwegian Forest Cat",
		"Ocicat",
		"Oriental",
		"Persian",
		"Pixie-bob",
		"Ragamuffin",
		"Ragdoll",
		"Russian Blue",
		"Savannah",
		"Scottish Fold",
		"Selkirk Rex",
		"Siamese",
		"Siberian",
		"Singapura",
		"Snowshoe",
		"Somali",
		"Sphynx",
		"Tonkinese",
		"Toyger",
		"Turkish Angora",
		"Turkish Van",
		"York Chocolate"
	]
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

	func testCatApiBreedName() {
		// Given
		var actualBreed = ""
		
		for i in 0..<breeds.count {
			
			let expectedBreed = breeds[i]
			let expectation = self.expectation(description: "Getting Cat Info - \(expectedBreed)")
			
			// When
			CatApi.getCatBreedInfo(breed: expectedBreed)
				.done { cat in
					// Cat API returns two JSON objects for Malayan
					if expectedBreed == "Malayan" {
						if let breed = cat[1,"name"].string {
							actualBreed = breed
							expectation.fulfill()
						}
					} else {
						if let breed = cat[0,"name"].string {
							actualBreed = breed
							expectation.fulfill()
						}
					}
				}.catch { error in
					XCTFail("Error from cat api \(error)")
				}
			
			// Then
			self.waitForExpectations(timeout: 4, handler: nil)
			print("Expected breed: \(expectedBreed), actual breed: \(actualBreed)")
			XCTAssert(actualBreed == expectedBreed, "Expected cat breed is \(expectedBreed), but actual is \(actualBreed)")
		}
    }

	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
}
