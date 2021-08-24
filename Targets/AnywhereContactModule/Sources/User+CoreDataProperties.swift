//
//  User+CoreDataProperties.swift
//  AnywhereContacts
//
//  Created by Vinoth on 11/06/21.
//
//

import Foundation
import CoreData

@objc(User)
public class User: BaseEntity, Decodable {
	
	// Overriding the part
	public enum BaseEntityCodingKeys: String, CodingKey {
		case accountId
		case imageUrl = "photoId"
		case createdAt
		case modifiedAt
		
		case id
		case name
		case color = "color" //
		case sortable = "sortable" //
	}
	
	required public init(from decoder: Decoder) throws {
		guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
			  let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
			fatalError("NSManagedObjectContext is missing")
		}
		super.init(entity: entity, insertInto: context)
		
		// Base
		let values = try decoder.container(keyedBy: BaseEntityCodingKeys.self)
		self.id = try values.decode(String.self, forKey: .id)
		self.accountId = try values.decode(String.self, forKey: .accountId)
		self.createdAt = try values.decode(Int64.self, forKey: .createdAt)
		self.modifiedAt = try values.decode(Int64.self, forKey: .modifiedAt)
		
		self.name = try values.decode(String.self, forKey: .name) // Not sure
		self.color = try values.decodeIfPresent(String.self, forKey: .color)
		self.sortable = try? SortableContact(from: decoder)
		
		// Others
	}
}

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

	@NSManaged public var status: String
	@NSManaged public var type: String
	@NSManaged public var login: String?
	
	@NSManaged public var firstName: String
	@NSManaged public var lastName: String?
	@NSManaged public var title: String?
	
	@NSManaged public var bot: Bool
    @NSManaged public var isGuest: Bool
    @NSManaged public var isPendingGuest: Bool
    @NSManaged public var isTemporary: Bool
    @NSManaged public var isVerified: Bool
	
	//@NSManaged var contactMethodWrapper: ContactMethodWrapper?
}

// Computeds
extension User {
	var fullName: String {
		guard let lastNameString = self.lastName,
			  !lastNameString.isEmpty else {
			return self.firstName
		}
		return "\(self.firstName) \(lastNameString)"
	}
	
	func saveUser() {
		
	}
}
