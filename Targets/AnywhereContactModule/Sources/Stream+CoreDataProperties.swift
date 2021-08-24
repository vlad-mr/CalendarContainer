//
//  Stream+CoreDataProperties.swift
//  AnywhereContacts
//
//  Created by Vinoth on 11/06/21.
//
//

import CoreData
import Foundation

@objc(Stream)
public class Stream: BaseEntity {
    public enum CodingKeys: String, CodingKey {
        case accountId
        case imageUrl = "photoId"
        case createdAt
        case modifiedAt

        case id
        case name
        case color //
        case sortable //
    }
}

public extension Stream {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Stream> {
        return NSFetchRequest<Stream>(entityName: "Stream")
    }

    @NSManaged var desc: String?
    @NSManaged var isGuest: NSNumber?
    @NSManaged var isPublic: NSNumber?
    @NSManaged var members: [User]?
    @NSManaged var status: String?
    @NSManaged var type: String?
    @NSManaged var vendorIds: NSObject?
}
