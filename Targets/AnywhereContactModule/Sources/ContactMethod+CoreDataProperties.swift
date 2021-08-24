//
//  ContactMethod+CoreDataProperties.swift
//  AnywhereContactModule
//
//  Created by Karthik on 17/06/21.
//
//

import Foundation
import CoreData

public class ContactMethod: NSManagedObject {
	
}

extension ContactMethod {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactMethod> {
        return NSFetchRequest<ContactMethod>(entityName: "ContactMethod")
    }

    @NSManaged public var id: String
	@NSManaged public var userId: String
    
    @NSManaged public var scope: String
    @NSManaged public var status: String
    @NSManaged public var title: String
    @NSManaged public var type: String
    @NSManaged public var typeId: String
    @NSManaged public var value: String
	
	@NSManaged public var isPrimary: Bool
	@NSManaged public var isPrivate: Bool
	
	@NSManaged public var isSpecificPeopleCallFlowEnabled: Bool
	@NSManaged public var isCallTransferFlowEnabled: Bool
	@NSManaged public var isDeliveryMethodEnabled: Bool
	@NSManaged public var isOnCallFlowEnabled: Bool
}

