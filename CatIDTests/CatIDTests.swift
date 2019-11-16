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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCatApiBreedName() {
		// Given
		let expectation = self.expectation(description: "Getting Cat Info")
		let expectedBreed = "Persian"
		var actualBreed = ""
		
		// When
		CatApi.getCatBreedInfo(breed: expectedBreed)
			.done { cat in
				if let breed = cat[0,"name"].string {
					actualBreed = breed
				}
				expectation.fulfill()
			}.catch { error in
				XCTFail("Error from cat api \(error)")
			}
		
		// Then
		print("Expected breed: \(expectedBreed), actual breed: \(actualBreed)")
		waitForExpectations(timeout: 2, handler: nil)
		XCTAssert(actualBreed == expectedBreed, "Expected cat breed is \(expectedBreed), but actual is \(actualBreed)")
    }

	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
