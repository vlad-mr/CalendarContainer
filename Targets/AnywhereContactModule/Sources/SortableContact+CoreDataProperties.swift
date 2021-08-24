//
//  SortableContact+CoreDataProperties.swift
//  AnywhereContacts
//
//  Created by Vinoth on 11/06/21.
//
//

import Foundation
import CoreData

public class SortableContact: NSManagedObject, Decodable {
	
	private enum CodingKeys: String, CodingKey {
		case id
	}
	
	required convenience public init(from decoder: Decoder) throws {
		guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
			fatalError("NSManagedObjectContext is missing")
		}
		let entity = NSEntityDescription.entity(forEntityName: "SortableContact", in: context)!
		self.init(entity: entity, insertInto: context)
		
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try values.decode(String.self, forKey: .id)
	}
}

extension SortableContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SortableContact> {
        return NSFetchRequest<SortableContact>(entityName: "Sortable")
    }

    @NSManaged public var contact_type: String?
    @NSManaged public var contactGroup: String?
    @NSManaged public var id: String?
    @NSManaged public var secondarySortOrder: String?
    @NSManaged public var sectionOrder: NSNumber?
    @NSManaged public var sortOrder: NSNumber?
    @NSManaged public var contact: BaseEntity?
}

extension SortableContact: Identifiable {

}
