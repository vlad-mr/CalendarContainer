//
//  CoreDataManager.swift
//  Anytime
//
//  Created by Monica on 06/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord

public protocol CoreDataManagerProtocol {
    var containerUrl: URL? { get }
    func initStack()
    func initStack_unitTestingTarget()
    
    //Delete
    func clearStack()
    func clearStore()
    
    func clearAllEntities()
    func removeDatabase()
    func clearDatabase()
}

public let CoreDataBase: CoreDataManagerProtocol = MagicalRecordManager()

class MagicalRecordManager: CoreDataManagerProtocol {
    
    var containerUrl: URL? {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.anytime.coredata") else {
            Logger.warning("Shared Container url not found")
            return nil
        }
        return url
    }
    
    var storeUrl: URL? {
        
        let bundle = Bundle(for: MagicalRecordManager.self)
        
        guard let bundleUrl = bundle.url(forResource: "AnywhereDataStack", withExtension: "bundle"),
              let frameworkBundle = Bundle(url: bundleUrl),
              let modelUrl = frameworkBundle.url(forResource: "AnywhereEvents", withExtension: "momd"),
              let _ = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Managed object model not found")
        }
        
        return modelUrl.appendingPathComponent("AnywhereEvents.sqlite")
    }
    
    func initStack() {
        Logger.info("Initialising core data")
        guard let storeUrl = storeUrl else {
            Logger.error("Store URL not found")
            return
        }
        
        MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStore(at: storeUrl)
        MagicalRecord.setLoggingLevel(.off)
        NSManagedObjectContext.mr_rootSaving().mergePolicy = NSMergePolicy.overwrite
        NSManagedObjectContext.mr_default().mergePolicy = NSMergePolicy.overwrite
    }
    
    func initStack_unitTestingTarget() {
        MagicalRecord.cleanUp()
        MagicalRecord.setDefaultModelFrom(Event.self)
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
        NSManagedObjectContext.mr_rootSaving().mergePolicy = NSMergePolicy.overwrite
        NSManagedObjectContext.mr_default().mergePolicy = NSMergePolicy.overwrite
    }
    
    func clearStack() {
        Logger.debug("Clearing the core data stack")
        MagicalRecord.cleanUp()
    }
    
    func clearStore() {
        Logger.info("Removing the core data store")
        clearAllEntities()
    }
    
    public func clearAllEntities() {
        let context: NSManagedObjectContext = .mr_rootSaving()
        Event.mr_truncateAll(in: context)
        EventParrentConfiguration.mr_truncateAll(in: context)
        context.mr_saveToPersistentStore { (success, _) in
            Logger.info("Cleared all entities: \(success)")
            self.clearStack()
        }
    }
    
    public func removeDatabase() {
        do {
            guard let storeUrl = storeUrl else { return }
            try FileManager.default.removeItem(at: storeUrl)
            clearStack()
        } catch {
            Logger.error("Error in removing the persistent store \(error.localizedDescription)")
        }
    }
    
    public func clearDatabase() {
        guard let url = storeUrl else { return }
        guard let persistentStoreCoordinator = NSManagedObjectContext.mr_rootSaving().persistentStoreCoordinator else { return }
        //    let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            clearStack()
        } catch let error {
            Logger.warning("Attempted to clear persistent store: " + error.localizedDescription)
        }
    }
}
