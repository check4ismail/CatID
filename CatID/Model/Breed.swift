//
//  Breed.swift
//  CatID
//
//  Created by Ismail Elmaliki on 10/19/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import Foundation
import RealmSwift

class Breed: Object {
	@objc dynamic var breedName = ""
//	@objc dynamic var image: UIImageView?
	@objc dynamic var url = ""
}
