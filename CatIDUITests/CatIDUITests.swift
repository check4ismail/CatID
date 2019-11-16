//
//  CatIDUITests.swift
//  CatIDUITests
//
//  Created by Ismail Elmaliki on 11/14/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import XCTest
import SwiftyJSON
import Alamofire
import PromiseKit
@testable import CatID

class CatIDUITests: XCTestCase {

	let app = XCUIApplication()
	let value: String = ProcessInfo.processInfo.environment["CAT_API_KEY"]!
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
        continueAfterFailure = false
		app.launchArguments.append("--uitesting")
		app.launchEnvironment = ["CAT_API_KEY": value]
    }

    func testCatBreedDetailedInfo() {
		// Will verify cat breed detailed appears for each breed
		
        app.launch()
		
		for i in 0..<breeds.count {
			let breed = breeds[i]
			app.cells.children(matching: .textField).element(boundBy: i).tap()
			
			sleep(2)
			
			// There should be 4 static texts:
			// 1) navigationBar title, 2) Temperament, 3) Summary, 4) Wiki hyperlink
			let actualStaticTextCount = app.staticTexts.allElementsBoundByIndex.count
			let expectedStaticTextCount = 4
			XCTAssert(actualStaticTextCount == expectedStaticTextCount, "There's a missing static text in \(breed) cat detailed view")
			
			// There should be 10 textviews: 5 rating texts and 5 rating values
			let actualTextFieldCount = app.textFields.allElementsBoundByIndex.count
			let expectedTextFieldCount = 10
			XCTAssert(actualTextFieldCount == expectedTextFieldCount, "There's a missing textfield in \(breed) cat detailed view")
			
			// There should be only 1 UIImage displayed
			let actualImageCount = app.images.allElementsBoundByIndex.count
			let expectedImageCount = 1
			XCTAssert(actualImageCount == expectedImageCount, "Image is missing in \(breed) cat detailed view")
			
			// Go back to list of cat breeds
			app.navigationBars.buttons["Cat ID"].tap()
		}
    }
	
	func testSearchBarEachBreed() {
		app.launch()
	
		for breed in breeds {
			/*
				Tap on search bar, then search for breed.
				Verify search results displays cell with exact cat breed, then reset search and repeat
				for the next breed.
			*/
			app.searchFields["Search"].tap()
			app.typeText(breed)
			XCTAssert(app.tables.staticTexts[breed].isHittable)
			app.searchFields["Search"].buttons["Clear text"].tap()
			app.buttons["Cancel"].tap()
		}
	}
	
	override func tearDown() {
		   // Put teardown code here. This method is called after the invocation of each test method in the class.
	}
}
