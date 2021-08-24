//
//  User+CoreDataProperties.swift
//  AnywhereContacts
//
//  Created by Vinoth on 11/06/21.
//
//

import CoreData
import Foundation

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
        case color //
        case sortable //
    }

    public required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        else {
            fatalError("NSManagedObjectContext is missing")
        }
        super.init(entity: entity, insertInto: context)

        // Base
        let values = try decoder.container(keyedBy: BaseEntityCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        accountId = try values.decode(String.self, forKey: .accountId)
        createdAt = try values.decode(Int64.self, forKey: .createdAt)
        modifiedAt = try values.decode(Int64.self, forKey: .modifiedAt)

        name = try values.decode(String.self, forKey: .name) // Not sure
        color = try values.decodeIfPresent(String.self, forKey: .color)
        sortable = try? SortableContact(from: decoder)

        // Others
    }
}

public extension User {
    @nonobjc class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged var status: String
    @NSManaged var type: String
    @NSManaged var login: String?

    @NSManaged var firstName: String
    @NSManaged var lastName: String?
    @NSManaged var title: String?

    @NSManaged var bot: Bool
    @NSManaged var isGuest: Bool
    @NSManaged var isPendingGuest: Bool
    @NSManaged var isTemporary: Bool
    @NSManaged var isVerified: Bool

    // @NSManaged var contactMethodWrapper: ContactMethodWrapper?
}

// Computeds
extension User {
    var fullName: String {
        guard let lastNameString = lastName,
              !lastNameString.isEmpty
        else {
            return firstName
        }
        return "\(firstName) \(lastNameString)"
    }

    func saveUser() {}
}
