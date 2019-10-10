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
	
	func getBreeds() -> [String] {
		return breeds
	}
}
