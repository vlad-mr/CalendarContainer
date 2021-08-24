//
//  ContactMethod+CoreDataProperties.swift
//  AnywhereContactModule
//
//  Created by Karthik on 17/06/21.
//
//

import CoreData
import Foundation

public class ContactMethod: NSManagedObject {}

public extension ContactMethod {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ContactMethod> {
        return NSFetchRequest<ContactMethod>(entityName: "ContactMethod")
    }

    @NSManaged var id: String
    @NSManaged var userId: String

    @NSManaged var scope: String
    @NSManaged var status: String
    @NSManaged var title: String
    @NSManaged var type: String
    @NSManaged var typeId: String
    @NSManaged var value: String

    @NSManaged var isPrimary: Bool
    @NSManaged var isPrivate: Bool

    @NSManaged var isSpecificPeopleCallFlowEnabled: Bool
    @NSManaged var isCallTransferFlowEnabled: Bool
    @NSManaged var isDeliveryMethodEnabled: Bool
    @NSManaged var isOnCallFlowEnabled: Bool
}
