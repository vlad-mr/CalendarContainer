//
//  Stream+CoreDataProperties.swift
//  AnywhereContacts
//
//  Created by Vinoth on 11/06/21.
//
//

import Foundation
import CoreData

@objc(Stream)
public class Stream: BaseEntity {
	
	public enum CodingKeys: String, CodingKey {
		case accountId
		case imageUrl = "photoId"
		case createdAt
		case modifiedAt
		
		case id
		case name
		case color = "color" //
		case sortable = "sortable" //
	}
}

extension Stream {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stream> {
        return NSFetchRequest<Stream>(entityName: "Stream")
    }

    @NSManaged public var desc: String?
    @NSManaged public var isGuest: NSNumber?
    @NSManaged public var isPublic: NSNumber?
    @NSManaged public var members: [User]?
    @NSManaged public var status: String?
    @NSManaged public var type: String?
    @NSManaged public var vendorIds: NSObject?
}
