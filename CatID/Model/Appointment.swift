//
//  Appointment.swift
//  CatID
//
//  Created by Ismail Elmaliki on 3/14/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//

import Foundation

public class Appointment: NSObject, NSCoding {
	public var startDate: Date?
	public var endDate: Date?
	public var identifier: String?
	
	enum Key:String {
		case startDate = "startDate"
		case endDate = "endDate"
		case identifier = "identifier"
	}
	
	init(startDate: Date, endDate: Date, identifier: String) {
		self.startDate = startDate
		self.endDate = endDate
		self.identifier = identifier
	}
	
	public override init() {
		super.init()
	}
	
	public func encode(with coder: NSCoder) {
		coder.encode(startDate, forKey: Key.startDate.rawValue)
		coder.encode(endDate, forKey: Key.endDate.rawValue)
		coder.encode(identifier, forKey: Key.identifier.rawValue)
	}
	
	public required convenience init?(coder: NSCoder) {
		let mStartDate = coder.decodeObject(forKey: "startDate") as! Date
		let mEndDate = coder.decodeObject(forKey: "endDate") as! Date
		let mIdentifier = coder.decodeObject(forKey: "identifier") as! String
		
		self.init(startDate: mStartDate, endDate: mEndDate, identifier: mIdentifier)
	}
	
	// MARK: Operator overloading
	static func >(lhs: Appointment, rhs: Appointment) -> Bool {
		guard checkStartDates(lhs, rhs) else {
			return false
		}
		if lhs.startDate! > rhs.startDate! {
			return true
		} else {
			return false
		}
	}
	
	static func >=(lhs: Appointment, rhs: Appointment) -> Bool {
		guard checkStartDates(lhs, rhs) else {
			return false
		}
		if lhs.startDate! >= rhs.startDate! {
			return true
		} else {
			return false
		}
	}
	
	static func <(lhs: Appointment, rhs: Appointment) -> Bool {
		guard checkStartDates(lhs, rhs) else {
			return false
		}
		if lhs.startDate! < rhs.startDate! {
			return true
		} else {
			return false
		}
	}
	
	static func <=(lhs: Appointment, rhs: Appointment) -> Bool {
		guard checkStartDates(lhs, rhs) else {
			return false
		}
		if lhs.startDate! <= rhs.startDate! {
			return true
		} else {
			return false
		}
	}
	
	static func checkStartDates(_ lhs: Appointment, _ rhs: Appointment) -> Bool {
		guard let _ = lhs.startDate else {
			return false
		}
		guard let _ = rhs.startDate else {
			return false
		}
		
		return true
	}
	
}
