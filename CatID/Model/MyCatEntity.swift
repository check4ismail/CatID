//
//  MyCatEntity.swift
//  CatID
//
//  Created by Ismail Elmaliki on 2/24/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import Foundation
import CoreData

@objc(MyCat)
class MyCat: NSManagedObject {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<MyCat> {
        return NSFetchRequest<Person>(entityName: "MyCat")
    }
	
//	@NSManaged 
}
