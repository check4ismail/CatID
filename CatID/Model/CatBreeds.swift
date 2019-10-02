//
//  CatBreeds.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/28/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import Foundation

struct CatBreeds {
	private let breeds = [
		"Abyssinian",
		"Aegean",
		"American Bobtail",
		"American Curl",
		"American Shorthair",
		"American Wirehair",
		"Balinese",
		"Bengal",
		"Birman",
		"Bombay",
		"British Shorthair",
		"Burmese",
		"Burmilla",
		"Chartreux",
		"Cornish Rex",
		"Cymric",
		"Devon Rex",
		"Egyptian Mau",
		"Exotic Shorthair",
		"Havana Brown",
		"Himalayan",
		"Japanese Bobtail",
		"Javanese",
		"Korat",
		"Kurilian Bobtail",
		"LaPerm",
		"Li Hua",
		"Maine Coon",
		"Manx",
		"Munchkin",
		"Norwegian Forest",
		"Ocicat",
		"Oriental",
		"Persian",
		"Pixiebob",
		"Ragamuffin",
		"Ragdoll",
		"Russian Blue",
		"Savannah",
		"Scottish Fold",
		"Selkirk Rex",
		"Siamese",
		"Siberian",
		"Singapura",
		"Somali",
		"Sphynx",
		"Tonkinese",
		"Toyger",
		"Turkish Angora",
		"Turkish Van"
	]
	
	func getBreeds() -> [String] {
		return breeds
	}
}
