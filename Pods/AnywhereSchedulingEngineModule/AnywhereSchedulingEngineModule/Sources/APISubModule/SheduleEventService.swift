//
//  EventsService.swift
//  Anytime
//
//  Created by Monica on 24/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import PromiseKit

public protocol SheduleEventServiceProtocol {
    
    //Methods to fetch events
    func fetchEvents(withParam param: [String: Any], shouldRefresh: Bool, shouldLoadNext: Bool) -> Promise<EventFetchResponse>
    func fetchEvents(withIds eventIds: [String]) -> Promise<EventFetchResponse>
    func fetchRecurringEvent(withParentID parentId: String?) -> Promise<EventFetchResponse>
    
    //Method to create event
    func createEvent(withParameters params: [String: Any]) -> Promise<EventModel>
    func createParrentConfigurationOfRecurringEvent(withParameters params: [String: Any]) -> Promise<Void>
    
    //Method to update event
    func updateEvent(withParameters params: [String: Any]) -> Promise<EventModel>
    
    func updateEventToRecurring(eventID: String, withParameters params: [String: Any]) -> Promise<Void>
    func updateRecurringToEvent(with parentId: String, withParameters params: [String: Any]) -> Promise<Void>
    
    //Method to delete the event
    func deleteEvent(with params: [String: Any], id: String) -> Promise<Void>
    func deleteParrentConfigurationOfRecurringEvent(with params: [String: Any], id: String) -> Promise<Void>
    func deleteTail(with params: [String: Any], withParrentId parrentId: String, afterDate date: Date) -> Promise<Void>

    func getParrentConfigurationOfRecurringEvent(withId id: String) -> Promise<Void>
    func updateRecurringEvent(with parentId: String, and params: [String: Any]) -> Promise<Void>
    func updateTail(withId params: [String: Any], withParrentId parrentId: String, afterDate date: Date) -> Promise<Void>
    
    //Method to set inform our availability to the event
    func updateResponse(forEvent eventId: String, withResponse responseStatus: ResponseStatus) -> Promise<EventModel>
    
    //Methods to save events into the local store
    func saveEvent(forResponse eventFetchResponse: EventFetchResponse?, shouldRefresh: Bool) -> Promise<EventFetchResponse>
    func saveEvents(_ eventModels: [EventModel]) -> Promise<[EventModel]>
    func saveEvent(_ eventModel: EventModel?) -> Promise<EventModel>
    
    //Mehtods to delete the events from the local store
    func deleteEventsFromLocalStore(withKeys keys: [String]) -> Promise<Void>
    func deleteEventsFromLocalStore(withParentIds parentIds: [String]) -> Promise<Void>
    func deleteEventsFromLocalStore(withCalendarIds calendarId: [String]) -> Promise<Void>
    func deleteEventsFromLocalStore(withParentIds parentIds: [String], andAfter date: Date) -> Promise<Void>
    func deleteParrentConfigurationFromLocalStore(withId id: String?) -> Promise<Void>
    func getEventsFromLocalStore(_ predicate: NSPredicate) -> Promise<[EventModel]?>
}

final class SheduleEventService: SheduleEventServiceProtocol {
    
    let api: EventsApiProtocol
    let dataStackProvider: AnywhereDataProviderType
    
    init(api: EventsApiProtocol, dataStackProvider: AnywhereDataProviderType) {
        self.api = api
        self.dataStackProvider = dataStackProvider
    }
    var startTime = 0
    var endTime = 0
    
    // MARK: Fetch Events by param
    func fetchEvents(withParam param: [String: Any], shouldRefresh: Bool = false, shouldLoadNext: Bool = true) -> Promise<EventFetchResponse> {
        if shouldRefresh {
            if let start = param["startTime"] as? Int {
                startTime = start
            }
            if let end = param["endTime"] as? Int {
                endTime = end
            }
        }
        return Promise<EventFetchResponse> { promise in
            firstly {
                api.fetchEvents(withParam: param)
            }.compactMap {
                SchedulingEngineApiResponse<EventFetchResponse>.decode(fromJsonData: $0)
            }.then { response in
                self.saveEvent(forResponse: response.data, shouldRefresh: shouldRefresh)
            }.done { eventResponse in
//                for event in eventResponse.events where !event.isExternal {
//                    if let parentId = event.parentId {
//                        self.getParrentConfigurationOfRecurringEvent(withId: parentId)
//                            .catch { promise.reject($0) }
//                    }
//                }
//                if let cursor = eventResponse.next_cursor, shouldLoadNext {
//                    var newEventFetchParam = param
//                    newEventFetchParam["cursorStr"] = cursor
//                    self.fetchMoreEvents(withParam: newEventFetchParam, promise: promise)
//                } else {
//                    if let start = param["startTime"] as? Int, let end = param["endTime"] as? Int {
//                        let startDate = Date(milliseconds: start)
//                        let endDate = Date(milliseconds: end)
//
//                        eventResponse.events
//                            .flatMap({ $0.provider })
//                            .forEach { FetchedDatesInfo.shared.addFetchedDates(from: startDate, to: endDate, for: $0) }
//                    }
//                    promise.fulfill(eventResponse)
//                }
                promise.fulfill(eventResponse)

            }.catch {
                promise.reject($0)
                Logger.warning("Error in fetching events \($0)")
            }
        }
    }
    
    private func fetchMoreEvents(withParam param: [String: Any], promise: Resolver<EventFetchResponse>) {
        firstly {
            api.fetchEvents(withParam: param)
        }.compactMap {
            SchedulingEngineApiResponse<EventFetchResponse>.decode(fromJsonData: $0)
        }.then { response in
            self.saveEvent(forResponse: response.data)
        }.done { eventResponse in
            if let cursor = eventResponse.next_cursor {
                var newEventFetchParam = param
                newEventFetchParam["cursorStr"] = cursor
                self.fetchMoreEvents(withParam: newEventFetchParam, promise: promise)
            } else {
                if let start = param["startTime"] as? Int, let end = param["endTime"] as? Int {
                    let startDate = Date(milliseconds: start)
                    let endDate = Date(milliseconds: end)
                    
                    eventResponse.events
                        .flatMap({ $0.provider })
                        .forEach { FetchedDatesInfo.shared.addFetchedDates(from: startDate, to: endDate, for: $0) }

                }
                promise.fulfill(eventResponse)
            }
        }.catch {
            promise.reject($0)
            Logger.warning("Error in fetching events \($0)")
        }
        
    }
    
    // MARK: Fetch Events by eventIds
    func fetchEvents(withIds eventIds: [String]) -> Promise<EventFetchResponse> {
        var param: [String: Any] = ["limit": 30, "eventIds": eventIds]
        return Promise {  promise in
            firstly {
                api.fetchEvents(withParam: param)
            }.compactMap { data in
                SchedulingEngineApiResponse<EventFetchResponse>.decode(fromJsonData: data)
            }.then { eventResponse in
                self.saveEvent(forResponse: eventResponse.data)
            }.done { eventResponse in
                if let cursor = eventResponse.next_cursor {
                    param["cursorStr"] = cursor
                    self.fetchMoreEvents(withParam: param, promise: promise)
                } else {
                    promise.fulfill(eventResponse)
                }
            }.catch {
                promise.reject($0)
            }
        }
    }

    // MARK: Fetch Events by parentId
    func fetchRecurringEvent(withParentID parentId: String?) -> Promise<EventFetchResponse> {

        return Promise { promise in
            guard let id = parentId else {
                promise.reject(APIError.missingData)
                return
            }
            var param: [String: Any] = ["parentId": id]

            firstly {
                deleteEventsFromLocalStore(withParentIds: [id])
            }.then {
                self.api.fetchEvents(withParam: param)
            }.compactMap { data in
                SchedulingEngineApiResponse<EventFetchResponse>.decode(fromJsonData: data)
            }.then { eventResponse in
                self.saveEvent(forResponse: eventResponse.data)
            }.done { eventResponse in
                if let cursor = eventResponse.next_cursor {
                    param["cursorStr"] = cursor
                    self.fetchMoreEvents(withParam: param, promise: promise)
                } else {
                    promise.fulfill(eventResponse)
                }
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func createEvent(withParameters params: [String: Any]) -> Promise<EventModel> {
        
        return Promise<EventModel> { promise in
            firstly {
                self.api.createEvent(withParameters: params)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.then { event in
                self.saveEvent(event.first)
            }.done { event in
                Logger.info("Create event successful and saved in core data pod=)")
                promise.fulfill(event)
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func createParrentConfigurationOfRecurringEvent(withParameters params: [String: Any]) -> Promise<Void> {
        return Promise<Void> { promise in
            firstly {
                self.api.createRecurring(withParameters: params)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.then {
                self.saveParrents($0)
            }.then {
                self.fetchRecurringEvent(withParentID: $0.first?.id)
            }.done { _ in
                Logger.info("Create event successful and saved in core data")
                promise.fulfill_()
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    private func validateResponse(_ response: SchedulingEngineApiResponse<[EventModel]>) -> Promise<[EventModel]> {
        return Promise<[EventModel]> { promise in
            guard let events = response.data else {
                if let error = response.error {
                    promise.reject(AppError(rawValue: error)!)
                }
                return
            }
            promise.fulfill(events)
        }
    }
    
    func updateEvent(withParameters params: [String: Any]) -> Promise<EventModel> {
        
        return Promise<EventModel> { promise in
            firstly {
                self.api.updateEvent(withParameters: params)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.then { event in
                self.saveEvent(event.first)
            }.done { event in
                Logger.info("Update event successful and saved in core data")
                promise.fulfill(event)
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func updateRecurringEvent(with parentId: String, and params: [String: Any]) -> Promise<Void> {
        return Promise<Void> { promise in
            firstly {
                deleteEventsFromLocalStore(withParentIds: [parentId])
            }.then {
                self.api.updateRecurringEvent(withParameters: params)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.then {
                self.saveParrents($0)
            }.then {
                self.fetchRecurringEvent(withParentID: $0.first?.id)
            }.done { _ in
                Logger.info("UpdateRecurringEvent successful and saved in core data")
                promise.fulfill_()
            }.catch {
                promise.reject($0)
            }
        }
    }
    func updateTail(withId params: [String: Any], withParrentId parrentId: String, afterDate date: Date) -> Promise<Void> {
        return Promise<Void> { promise in
            firstly {
                deleteEventsFromLocalStore(withParentIds: [parrentId], andAfter: date)
            }.then {
                self.api.updateTail(withParameters: params)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.then {
                self.saveParrents($0)
            }.then {
                self.fetchRecurringEvent(withParentID: $0.first?.id)
            }.done { _ in
                promise.fulfill(())
            }.catch {
                promise.reject($0)
            }
            
        }
    }
    
    func updateRecurringToEvent(with parentId: String, withParameters params: [String: Any]) -> Promise<Void> {
        return Promise<Void> { promise in
            
            firstly {
                self.deleteParrentConfigurationFromLocalStore(withId: parentId)
            }.then {
                self.deleteEventsFromLocalStore(withParentIds: [parentId])
            }.then {
                self.api.recurringToEvent(withParameters: params)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.then {
                self.saveEvents($0)
            }.done { _ in
                Logger.info("RECUR TO event success")
                promise.fulfill_()
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func updateEventToRecurring(eventID: String, withParameters params: [String: Any]) -> Promise<Void> {
        return Promise<Void> { promise in
            
            firstly {
                self.deleteEventsFromLocalStore(withKeys: [eventID])
            }.then {
                self.api.eventToRecurring(withParameters: params)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.then {
                self.saveParrents($0)
            }.then {
                self.fetchRecurringEvent(withParentID: $0.first?.id)
            }.done { _ in
                Logger.info("Create event successful and saved in core data")
                promise.fulfill_()
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    // MARK: Delete Events
    func deleteEvent(with params: [String: Any], id: String) -> Promise<Void> {
        return Promise<Void> { promise in
            firstly {
                self.api.deleteEvent(withParameters: params)
            }.then { _ in
                self.deleteEventsFromLocalStore(withKeys: [id])
            }.done { _ in
                promise.fulfill(())
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func deleteParrentConfigurationOfRecurringEvent(with params: [String: Any], id: String) -> Promise<Void> {
        return Promise<Void> { promise in
            firstly {
                self.api.deleteRecurringEvent(withParameters: params)
            }.then { _ in
                self.deleteParrentConfigurationFromLocalStore(withId: id)
            }.then { _ in
                self.deleteEventsFromLocalStore(withParentIds: [id])
            }.done { _ in
                promise.fulfill(())
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func deleteTail(with params: [String: Any], withParrentId parrentId: String, afterDate date: Date) -> Promise<Void> {
        return Promise<Void> { promise in
            firstly {
                self.api.deleteRecurringTail(withParameters: params)
            }.then { _ in
                self.deleteEventsFromLocalStore(withParentIds: [parrentId], andAfter: date)
            }.done { _ in
                promise.fulfill(())
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func updateResponse(forEvent eventId: String, withResponse responseStatus: ResponseStatus) -> Promise<EventModel> {
        return Promise<EventModel> { promise in
            firstly {
                self.api.updateResponseStatus(withEventId: eventId, andResponseStatus: responseStatus.rawValue)
            }.compactMap {
                SchedulingEngineApiResponse<[EventModel]>.decode(fromJsonData: $0)
            }.then {
                self.saveEvent($0.data?.first)
            }.done {
                promise.fulfill($0)
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    func getParrentConfigurationOfRecurringEvent(withId id: String) -> Promise<Void> {
        return Promise<Void> { promise in
            firstly {
                self.api.getRecurring(withId: id)
            }.compactMap {
                SchedulingEngineApiResponse<ParrentConfigClass>.decode(fromJsonData: $0)
            }.then { resp in
                self.saveParrents(resp.data!)
            }.done {
                promise.fulfill_()
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    // MARK: - Local Store methods
    func saveEvents(_ eventModels: [EventModel]) -> Promise<[EventModel]> {
        dataStackProvider.saveEvents(eventModels)
    }
    
    func saveEvent(_ eventModel: EventModel?) -> Promise<EventModel> {
        dataStackProvider.saveEvent(eventModel)
    }
    
    func saveEvent(forResponse eventFetchResponse: EventFetchResponse?, shouldRefresh: Bool = false) -> Promise<EventFetchResponse> {
        dataStackProvider.saveEvent(
            forResponse: eventFetchResponse,
            shouldRefresh: shouldRefresh,
            startTime: startTime,
            endTime: endTime
        )
    }
    
    func deleteEventsFromLocalStore(withKeys keys: [String]) -> Promise<Void> {
        dataStackProvider.deleteEventsFromLocalStore(withKeys: keys)
    }
    
    func deleteEventsFromLocalStore(withParentIds parentIds: [String]) -> Promise<Void> {
        dataStackProvider.deleteEventsFromLocalStore(withParentIds: parentIds)
    }
    
    func deleteEventsFromLocalStore(withParentIds parentIds: [String], andAfter date: Date) -> Promise<Void> {
        dataStackProvider.deleteEventsFromLocalStore(withParentIds: parentIds, andAfter: date)
    }
    
    func deleteEventsFromLocalStore(withCalendarIds calendarIds: [String]) -> Promise<Void> {
        dataStackProvider.deleteEventsFromLocalStore(withCalendarIds: calendarIds)
    }
    
    func saveParrents(_ events: [EventModel]) -> Promise<[EventModel]> {
        dataStackProvider.saveParrents(events)
    }
    
    func saveParrents(_ parrentModels: ParrentConfigClass) -> Promise<Void> {
        dataStackProvider.saveParrents(parrentModels)
    }
    
    func deleteParrentConfigurationFromLocalStore(withId id: String?) -> Promise<Void> {
        dataStackProvider.deleteParrentConfigurationFromLocalStore(withId: id)
    }
    func getEventsFromLocalStore(_ predicate: NSPredicate) -> Promise<[EventModel]?> {
        dataStackProvider.getEvents(predicate)
    }
}
