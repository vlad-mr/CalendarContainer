//
//  SortableContact+CoreDataProperties.swift
//  AnywhereContacts
//
//  Created by Vinoth on 11/06/21.
//
//

import CoreData
import Foundation

public class SortableContact: NSManagedObject, Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is missing")
        }
        let entity = NSEntityDescription.entity(forEntityName: "SortableContact", in: context)!
        self.init(entity: entity, insertInto: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
    }
}

public extension SortableContact {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SortableContact> {
        return NSFetchRequest<SortableContact>(entityName: "Sortable")
    }

    @NSManaged var contact_type: String?
    @NSManaged var contactGroup: String?
    @NSManaged var id: String?
    @NSManaged var secondarySortOrder: String?
    @NSManaged var sectionOrder: NSNumber?
    @NSManaged var sortOrder: NSNumber?
    @NSManaged var contact: BaseEntity?
}

extension SortableContact: Identifiable {}
