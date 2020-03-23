//
//  Appointment.swift
//  CatID
//
//  Created by Ismail Elmaliki on 3/13/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import Foundation
import EventKit

/*
	Events is used in order to have an array
	of appointments added to a single Core Data Entity
*/
public class Events: NSObject, NSCoding {
	
	public var events: [Appointment] = []
	
	enum Key: String {
		case events = "events"
	}
	
	init(events: [Appointment]) {
		self.events = events
	}
	
	public func encode(with coder: NSCoder) {
		coder.encode(events, forKey: Key.events.rawValue)
	}
	
	public required convenience init?(coder: NSCoder) {
		let mEvents = coder.decodeObject(forKey: Key.events.rawValue) as! [Appointment]
		
		self.init(events: mEvents)
	}
}
