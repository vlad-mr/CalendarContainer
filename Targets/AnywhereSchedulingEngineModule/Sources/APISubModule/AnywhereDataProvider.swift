//
//  AnywhereDataProvider.swift
//  AnywhereDataStack
//
//  Created by Illia Postoienko on 22.07.2021.
//

import CoreData
import Foundation
import PromiseKit

public protocol AnywhereDataProviderType {
    func saveEvent(forResponse eventFetchResponse: EventFetchResponse?, shouldRefresh: Bool, startTime: Int, endTime: Int) -> Promise<EventFetchResponse>
    func saveEvents(_ eventModels: [EventModel]) -> Promise<[EventModel]>
    func saveEvent(_ eventModel: EventModel?) -> Promise<EventModel>

    func deleteEventsFromLocalStore(withKeys keys: [String]) -> Promise<Void>

    func deleteEventsFromLocalStore(withParentIds parentIds: [String]) -> Promise<Void>
    func deleteEventsFromLocalStore(withParentIds parentIds: [String], andAfter date: Date) -> Promise<Void>
    func deleteEventsFromLocalStore(withCalendarIds calendarIds: [String]) -> Promise<Void>

    func saveParrents(_ events: [EventModel]) -> Promise<[EventModel]>
    func saveParrents(_ parrentModels: ParrentConfigClass) -> Promise<Void>
    func deleteParrentConfigurationFromLocalStore(withId id: String?) -> Promise<Void>
}

public enum DataStackError: String, Error {
    case missingData
}

final class AnywhereDataProvider: AnywhereDataProviderType {
    var isClear = false

    func saveEvent(forResponse eventFetchResponse: EventFetchResponse?, shouldRefresh: Bool = false, startTime: Int, endTime: Int) -> Promise<EventFetchResponse> {
        isClear = false

        return Promise<EventFetchResponse> { promise in
            guard let response = eventFetchResponse else {
                promise.reject(DataStackError.missingData)
                return
            }

            let context = NSManagedObjectContext.mr_()

            if !isClear, shouldRefresh {
                context.performAndWait {
                    let predicate = CoreDataHelper.getEventFetchPredicate(forStartTime: Double(startTime), endTime: Double(endTime))
                    isClear = Event.mr_deleteAll(matching: predicate, in: context)
                    Logger.debug("Events deleted: \(isClear)")
                }
            }

            context.performAndWait {
                for eventModel in response.events where eventModel.brand.isAllowed {
                    let event = Event.mr_findFirstOrCreate(byAttribute: "id", withValue: eventModel.id, in: context)
                    event.setEvent(eventModel)
                }
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill(response)
            }
        }
    }

    func saveEvents(_ eventModels: [EventModel]) -> Promise<[EventModel]> {
        return Promise<[EventModel]> { promise in

            let context = NSManagedObjectContext.mr_()
            context.performAndWait {
                for eventModel in eventModels where eventModel.brand.isAllowed {
                    let event = Event.mr_findFirstOrCreate(byAttribute: "id", withValue: eventModel.id, in: context)
                    event.setEvent(eventModel)
                }
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill(eventModels)
            }
        }
    }

    func saveEvent(_ eventModel: EventModel?) -> Promise<EventModel> {
        return Promise<EventModel> { promise in

            let context = NSManagedObjectContext.mr_()
            guard let eventToSave = eventModel, eventToSave.brand.isAllowed else {
                promise.reject(DataStackError.missingData)
                return
            }

            context.performAndWait {
                let event = Event.mr_findFirstOrCreate(byAttribute: "id", withValue: eventToSave.id, in: context)
                event.setEvent(eventToSave)
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill(eventToSave)
            }
        }
    }

    func deleteEventsFromLocalStore(withKeys keys: [String]) -> Promise<Void> {
        return Promise<Void> { promise in
            let context = NSManagedObjectContext.mr_()
            guard !keys.isEmpty else {
                promise.reject(DataStackError.missingData)
                return
            }
            let predicate = CoreDataHelper.getEventsFetchPredicate(forKeys: keys)

            context.performAndWait {
                _ = Event.mr_deleteAll(matching: predicate, in: context)
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill_()
            }
        }
    }

    func deleteEventsFromLocalStore(withParentIds parentIds: [String]) -> Promise<Void> {
        return Promise<Void> { promise in
            let context = NSManagedObjectContext.mr_()
            guard !parentIds.isEmpty else {
                promise.reject(DataStackError.missingData)
                return
            }
            let predicate = CoreDataHelper.getEventsFetchPredicate(forParentIds: parentIds)

            context.performAndWait {
                _ = Event.mr_deleteAll(matching: predicate, in: context)
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill_()
            }
        }
    }

    func deleteEventsFromLocalStore(withParentIds parentIds: [String], andAfter date: Date) -> Promise<Void> {
        return Promise<Void> { promise in
            let context = NSManagedObjectContext.mr_()
            guard !parentIds.isEmpty else {
                promise.reject(DataStackError.missingData)
                return
            }
            let predicate = CoreDataHelper.getEventsFetchPredicate(forParentIds: parentIds, afterDate: date)

            context.performAndWait {
                _ = Event.mr_deleteAll(matching: predicate, in: context)
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill_()
            }
        }
    }

    func deleteEventsFromLocalStore(withCalendarIds calendarIds: [String]) -> Promise<Void> {
        return Promise<Void> { promise in
            let context = NSManagedObjectContext.mr_()
            guard !calendarIds.isEmpty else {
                promise.reject(DataStackError.missingData)
                return
            }
            let predicate = CoreDataHelper.getEventsFetchPredicate(forCalendarIds: calendarIds)

            context.performAndWait {
                _ = Event.mr_deleteAll(matching: predicate, in: context)
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill_()
            }
        }
    }

    func saveParrents(_ events: [EventModel]) -> Promise<[EventModel]> {
        return Promise<[EventModel]> { promise in

            let context = NSManagedObjectContext.mr_()
            context.performAndWait {
                for model in events {
                    let parrent = EventParrentConfiguration.mr_findFirstOrCreate(byAttribute: "id", withValue: model.id, in: context)
                    parrent.setEvent(model)
                }
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill(events)
            }
        }
    }

    func saveParrents(_ parrentModels: ParrentConfigClass) -> Promise<Void> {
        return Promise<Void> { promise in

            let context = NSManagedObjectContext.mr_()
            context.performAndWait {
                for model in parrentModels.data {
                    let parrent = EventParrentConfiguration.mr_findFirstOrCreate(byAttribute: "id", withValue: model.id, in: context)
                    parrent.setEvent(model)
                }
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill_()
            }
        }
    }

    func deleteParrentConfigurationFromLocalStore(withId id: String?) -> Promise<Void> {
        return Promise<Void> { promise in
            let context = NSManagedObjectContext.mr_()
            guard let unwrappedId = id else {
                promise.reject(DataStackError.missingData)
                return
            }
            let predicate = CoreDataHelper.getEventFetchPredicate(forKey: unwrappedId)
            context.performAndWait {
                _ = EventParrentConfiguration.mr_deleteAll(matching: predicate, in: context)
            }
            context.mr_saveToPersistentStore { _, _ in
                promise.fulfill_()
            }
        }
    }
}
