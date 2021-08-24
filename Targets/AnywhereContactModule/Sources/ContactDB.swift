//
//  ContactDB.swift
//  AnywhereContactModule
//
//  Created by Karthik on 17/06/21.
//

import AnywhereInterfaceModule
import CoreData
import Foundation

// https://gist.github.com/Thongpak21/228abbba1be056ff11c88ca175df6c6d
// https://gist.github.com/racer1988/c5dae7623c58e2abd617856cc971f44d

// https://gist.github.com/karthikgs7/f4fd3676bed72c74e25af360c601e088
// https://gist.github.com/nitikorndev/ba730ada323bfd7fe8bb67186e04fb44

class ContactDB: DataBaseInterface {
    static let manager = ContactDB()

    var persistentContainer: NSPersistentContainer!

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    //	func initCoredata() -> NSPersistentContainer {
    //		let bundle = Bundle(identifier: "io.full.anywhereContactModule")!
    //		let modelURL = bundle.url(forResource: "AnywhereContacts", withExtension: "momd")!
    //		let mom = NSManagedObjectModel(contentsOf: modelURL)!
    //		let container = NSPersistentContainer(name: "AnywhereContacts", managedObjectModel: mom)
    //		let description = container.persistentStoreDescriptions.first!
    //		description.url = URL(fileURLWithPath: "/dev/null")
    //		try! container.persistentStoreCoordinator.destroyPersistentStore(at: URL(fileURLWithPath: "/dev/null"), ofType: NSSQLiteStoreType, options: [:])
    //		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
    //			if let error = error as NSError? {
    //				fatalError("Unresolved error \(error), \(error.userInfo)")
    //			}
    //		})
    //		return container
    //	}

    func initializeDataBase() {
        //		persistentContainer = initCoredata()
    }

    func reset() {
        initializeDataBase()
    }

    func saveUser(_: NSManagedObjectContext) {
        // create data
        // serialize
        // set into entity
        // save into coredata
    }
}
