//
//  CoreDataHelper.swift
//  AnywhereDataStack
//
//  Created by Illia Postoienko on 22.07.2021.
//

import Foundation
import CoreData

struct CoreDataHelper {

    static func getEventFetchPredicate(forStartTime startTime: Double, endTime: Double) -> NSPredicate {
        if endTime > 0 {
            return NSPredicate(format: "startTime BETWEEN {%@, %@}", argumentArray: [startTime, endTime])
        } else {
            return NSPredicate(format: "startTime >= %i", startTime)
        }
    }

    static func getEventFetchPredicate(forKey key: String) -> NSPredicate {
        NSPredicate(format: "id == %@", key)
    }

    static func getEventsFetchPredicate(forKeys keys: [String]) -> NSPredicate {
        NSPredicate(format: "id IN %@", keys)
    }

    static func getEventsFetchPredicate(forParentIds parentIds: [String]) -> NSPredicate {
        NSPredicate(format: "parentId IN %@", parentIds)
    }

    static func getEventsFetchPredicate(forParentIds parentIds: [String], afterDate date: Date) -> NSPredicate {
        let parentIdPredicate = NSPredicate(format: "parentId IN %@", parentIds)
        let datePredicate = NSPredicate(format: "startDate >= %@", date as NSDate)
        return NSCompoundPredicate(type: .and, subpredicates: [parentIdPredicate, datePredicate])
    }

    static func getEventFetchPredicate(forParentId parentId: String) -> NSPredicate {
        NSPredicate(format: "parentId == %@", parentId)
    }

    static func getEventFetchPredicate(forCalendarId calendarId: String) -> NSPredicate {
        NSPredicate(format: "calendar == %@", calendarId)
    }

    static func getEventsFetchPredicate(forCalendarIds calendarIds: [String]) -> NSPredicate {
        NSPredicate(format: "calendar IN %@", calendarIds)
    }
    
    static func getEventsFetchPredicate(forProvider key: String) -> NSPredicate {
        NSPredicate(format: "providerIdentifiers CONTAINS[cd] %@", key)
    }
    
    static func getEventsFetchPredicate(forProvider keys: [String]) -> NSPredicate {
        let queryPredicates = keys.map {
            getEventsFetchPredicate(forProvider: $0)
        }
        return NSCompoundPredicate(type: .or, subpredicates: queryPredicates)
    }
    
    static func getEventFetchPredicate(forProvider key: String, forStartTime startTime: Double, endTime: Double) -> NSPredicate {
        let queryPredicate = getEventsFetchPredicate(forProvider: key)

        let timebasedQuery = getEventFetchPredicate(forStartTime: startTime, endTime: endTime)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [queryPredicate, timebasedQuery])
    }
    
    static func getEventFetchPredicate(forProvider keys: [String], forStartTime startTime: Double, endTime: Double) -> NSPredicate {
        let queryPredicates = keys.map {
            getEventFetchPredicate(forProvider: $0, forStartTime: startTime, endTime: endTime)
        }
        return NSCompoundPredicate(type: .or, subpredicates: queryPredicates)
    }

}
