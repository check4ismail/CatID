//
//  CatBreeds.swift
//  CatID
//
//  Created by Ismail Elmaliki on 9/28/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import Foundation

struct CatBreeds {

	static let breeds = [
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
	
	static let breedIds = [
		"Abyssinian": "abys",
		"Aegean": "aege",
		"American Bobtail": "abob",
		"American Curl": "acur",
		"American Shorthair": "asho",
		"American Wirehair":	"awir",
		"Arabian Mau":	"amau",
		"Australian Mist":	"amis",
		"Balinese":	"bali",
		"Bambino":	"bamb",
		"Bengal":	"beng",
		"Birman":	"birm",
		"Bombay":	"bomb",
		"British Longhair":	"bslo",
		"British Shorthair":	"bsho",
		"Burmese":	"bure",
		"Burmilla":	"buri",
		"California Spangled":	"cspa",
		"Chantilly-Tiffany":	"ctif",
		"Chartreux":	"char",
		"Chausie":	"chau",
		"Cheetoh":	"chee",
		"Colorpoint Shorthair":	"csho",
		"Cornish Rex":	"crex",
		"Cymric":	"cymr",
		"Cyprus":	"cypr",
		"Devon Rex":	"drex",
		"Donskoy":	"dons",
		"Dragon Li":	"lihu",
		"Egyptian Mau":	"emau",
		"European Burmese":	"ebur",
		"Exotic Shorthair":	"esho",
		"Havana Brown":	"hbro",
		"Himalayan":	"hima",
		"Japanese Bobtail":	"jbob",
		"Javanese":	"java",
		"Khao Manee":	"khao",
		"Korat":	"kora",
		"Kurilian":	"kuri",
		"LaPerm":	"lape",
		"Maine Coon":	"mcoo",
		"Malayan":	"mala",
		"Manx":	"manx",
		"Munchkin":	"munc",
		"Nebelung":	"nebe",
		"Norwegian Forest Cat":	"norw",
		"Ocicat":	"ocic",
		"Oriental":	"orie",
		"Persian":	"pers",
		"Pixie-bob":	"pixi",
		"Ragamuffin":	"raga",
		"Ragdoll":	"ragd",
		"Russian Blue":	"rblu",
		"Savannah":	"sava",
		"Scottish Fold":	"sfol",
		"Selkirk Rex":	"srex",
		"Siamese":	"siam",
		"Siberian":	"sibe",
		"Singapura":	"sing",
		"Snowshoe":	"snow",
		"Somali":	"soma",
		"Sphynx":	"sphy",
		"Tonkinese":	"tonk",
		"Toyger":	"toyg",
		"Turkish Angora":	"tang",
		"Turkish Van":	"tvan",
		"York Chocolate":	"ycho"
	]
	
	static private var counter: [Int] = counterGeneratePhotos()
	static var imageUrls: [String : [URL]] = [:]
	
	static var defaultCatPhoto: [String : URL] = [:]
	
	static func nextImageUrl(_ breed: String) -> URL? {
		// Current breed's counter
		let index = breeds.firstIndex(of: breed)
		
		// Attempt to iterate to next URL for specific cat breed
		let newCounter = counter[index!] + 1
		if newCounter < imageUrls[breed]!.count {
			if let newDefaultPhoto = imageUrls[breed]?[newCounter] {
				counter[index!] += 1
				
				defaultCatPhoto[breed] = newDefaultPhoto
				return newDefaultPhoto
			}
		}
		
		// Default back to first URL for specific cat breed
		counter[index!] = 0
		defaultCatPhoto[breed] = imageUrls[breed]?[0]
		return imageUrls[breed]?[0]
	}
	
	static private func counterGeneratePhotos() -> [Int] {
		
		var count: [Int] = []
		for i in 0..<breeds.count {
			count.append(i)
		}
		
		return count
	}
}
