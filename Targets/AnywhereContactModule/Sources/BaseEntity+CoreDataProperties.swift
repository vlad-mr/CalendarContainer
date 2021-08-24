//
//  Contact+CoreDataProperties.swift
//  AnywhereContacts
//
//  Created by Vinoth on 11/06/21.
//
//

import CoreData
import Foundation

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

public extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        userInfo[.context] = context
    }
}

@objc(Contact)
public class BaseEntity: NSManagedObject {}

extension BaseEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<BaseEntity> {
        return NSFetchRequest<BaseEntity>(entityName: "Contact")
    }

    @NSManaged public var id: String
    @NSManaged var accountId: String
    @NSManaged var name: String
    @NSManaged var createdAt: Int64
    @NSManaged var modifiedAt: Int64
    @NSManaged var imageUrl: String?
    @NSManaged var color: String?
    @NSManaged var sortable: SortableContact?
}

extension BaseEntity: Identifiable {}
