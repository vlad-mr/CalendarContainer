//
//  SheduleEventServiceProvider.swift
//  AnywhereSchedulingEngineModule
//
//  Created by Artem Grebinik on 28.07.2021.
//

import Foundation
import PromiseKit

// MARK: - EventFetchConfig
public enum EventFetchConfig {
    case byEventIds(ids: [String])
    case byParentId(id: String)
    case providerIds(ids: [String], startTimeDate: Date, endTimeDate: Date)
    case byFetchParam(param: EventFetchParam)
}

public struct EventFetchParam: Codable {
    let calendarIds: [String]? = nil
    var providerIds: [String]? = nil
    let serviceIds: [String]? = nil
    let consumerIds: [String]? = nil
    let resourceIds: [String]? = nil
    let eventIds: [String]? = nil
    
    let merchantId: String? = nil
    var startTime: Double = 0
    var endTime: Double = 0
    let type: FetchEventType? = nil
    let parentId: String? = nil
    let cursorStr: String? = nil
    let isGroup: Bool = true
    var limit: Int = 30
}

public enum FetchEventType: String, Codable {
    case appointment = "APPOINTMENT"
    case event = "EVENT"
    case groupe = "GROUP"
    case offhours = "OFFHOURS"
    case session = "SESSION"
    case reminder = "REMINDER"
}

// MARK: - EventCreateConfig
public enum CreateConfig {
    case single
    case recurring
}

public struct EventCreateParam: Codable {
    var brand: AppBrand
    var merchant: String
    var action: EventActionType
    var data: [EventModel]
    var checkSlot: Bool = true
}

public extension EventCreateParam {
    init(withEvent event: EventModel, forAction action: EventActionType) {
        self.data = [event]
        self.merchant = event.merchant
        self.action = action
        self.brand = event.brand
    }
}

// MARK: - EventDeleteConfig
public enum EventDeleteConfig {
    case single(id: String)
    case recurring(id: String)
    case tail(id: String, parrentID: String, afterDate: Date)
}

public struct EventDeleteParam: Codable {
    var key: String
    var action: EventDeleteActionType
}

public enum EventDeleteActionType: String, Codable {
    case event = "EVENT"
    case recurring = "RECURRING"
    case tail = "TAIL"
}

public enum EventActionType: String, Codable {
    case create = "EVENT_CREATE"
    case update = "EVENT_UPDATE"
    
    case recurringCreate = "RECURRING_CREATE"
    case recurringUpdate = "RECURRING_UPDATE"
    case tail = "TAIL"
    case recurringToEvent = "RECURRING_TO_EVENT"
    case eventToRecurring = "EVENT_TO_RECURRING"
}

public enum CreateUpdateEventAction {
    case create, update
}

public enum SwitchEventTypeAction {
    case eventToRecurring, recurringToEvent
}

public enum LocalStorageDeleteAction {
    case eventWithKeys(keys: [String])
    case eventWithParentIds(parentIds: [String])
    case eventWithCalendarIds(calendarIds: [String])
    case eventWithParentId(parentIds: [String], afterDate: Date)
    case parrentConfigurationWith(id: String)
}

public protocol SheduleEventServiceProviderProtocol {
    func singleEvent(action: CreateUpdateEventAction, model: EventModel) -> Promise<EventModel>
    func fetchEvents(with config: EventFetchConfig, shouldRefresh: Bool, shouldLoadNext: Bool) -> Promise<EventFetchResponse>
    func deleteEvent(with config: EventDeleteConfig) -> Promise<Void>
    func updateEvent(action: SwitchEventTypeAction, withParameters params: EventCreateParam) -> Promise<Void>
    func recurringEvent(action: CreateUpdateEventAction, model: EventModel) -> Promise<Void>
    func updateTail(with model: EventModel, afterDate date: Date) -> Promise<Void>
    
    //Mehtods to delete the events from the local store
    func deleteEventsFromLocalStore(action: LocalStorageDeleteAction) -> Promise<Void>
    func updateResponse(forEvent eventId: String, withResponse responseStatus: ResponseStatus) -> Promise<EventModel>
    func saveEvent(forResponse eventFetchResponse: EventFetchResponse?, shouldRefresh: Bool) -> Promise<EventFetchResponse>
    func saveEvents(_ eventModels: [EventModel]) -> Promise<[EventModel]>
    func saveEvent(_ eventModel: EventModel?) -> Promise<EventModel>
}

final class SheduleEventServiceProvider: SheduleEventServiceProviderProtocol {
    let service: SheduleEventServiceProtocol
    
    init(service: SheduleEventServiceProtocol) {
        self.service = service
    }

    func updateTail(with model: EventModel, afterDate date: Date) -> Promise<Void> {
        let createParam = EventCreateParam(withEvent: model, forAction: .tail)
        let parentId = createParam.data[0].parentId ?? ""
        let param = createParam.dictionary ?? [:]
        return service.updateTail(withId: param, withParrentId: parentId, afterDate: date)
    }
    func recurringEvent(action: CreateUpdateEventAction, model: EventModel) -> Promise<Void> {
        switch action {
        case .create:
            let createParam = EventCreateParam(withEvent: model, forAction: .recurringCreate)
            let param = createParam.dictionary ?? [:]
            return service.createParrentConfigurationOfRecurringEvent(withParameters: param)
        case .update:
            let createParam = EventCreateParam(withEvent: model, forAction: .recurringUpdate)
            let parentId = createParam.data[0].parentId ?? ""
            let param = createParam.dictionary ?? [:]
            return service.updateRecurringEvent(with: parentId, and: param)
        }
    }
    
    func updateEvent(action: SwitchEventTypeAction, withParameters params: EventCreateParam) -> Promise<Void> {
        let param = params.dictionary ?? [:]
        
        switch action {
        case .eventToRecurring:
            let id = params.data[0].id
            return service.updateEventToRecurring(eventID: id, withParameters: param)
        case .recurringToEvent:
            //we must pass the evenModel id = parentId(maybe needs to swap ids)
            let id = params.data[0].parentId ?? ""
            return service.updateRecurringToEvent(with: id, withParameters: param)
        }
    }

    func singleEvent(action: CreateUpdateEventAction, model: EventModel) -> Promise<EventModel> {
        switch action {
        case .create:
            let createParam = EventCreateParam(withEvent: model, forAction: .create)
            let param = createParam.dictionary ?? [:]
            return service.createEvent(withParameters: param)

        case .update:
            let updateParam = EventCreateParam(withEvent: model, forAction: .update)
            let param = updateParam.dictionary ?? [:]
            return service.updateEvent(withParameters: param)
        }
    }
    
    func deleteEvent(with config: EventDeleteConfig) -> Promise<Void> {
        switch config {
        case let .single(id):
            let deleteParam = EventDeleteParam(key: id, action: .event)
            let param = deleteParam.dictionary ?? [:]
            return service.deleteEvent(with: param, id: id)
      
        case let .recurring(id):
            let deleteParam = EventDeleteParam(key: id, action: .recurring)
            let param = deleteParam.dictionary ?? [:]
            return service.deleteParrentConfigurationOfRecurringEvent(with: param, id: id)
       
        case let .tail(id, parrentID, afterDate):
            let deleteParam = EventDeleteParam(key: id, action: .tail)
            let param = deleteParam.dictionary ?? [:]
            return service.deleteTail(with: param, withParrentId: parrentID, afterDate: afterDate)
        }
    }

    func fetchEvents(with config: EventFetchConfig, shouldRefresh: Bool, shouldLoadNext: Bool) -> Promise<EventFetchResponse> {
        switch config {

        case let .byEventIds(ids):
            return service.fetchEvents(withIds: ids)

        case let .byParentId(id):
            return service.fetchRecurringEvent(withParentID: id)

        case let .providerIds(ids, startTimeDate, endTimedate):
            
            guard !ids.isEmpty else {
                return Promise<EventFetchResponse> { promise in
                    promise.reject(APIError.missingData)
            } }
            
            let nonFetchedIds = ids.filter { !FetchedDatesInfo.shared.areDatesAlreadyFetched(from: startTimeDate, to: endTimedate, for: $0) }
            
            guard !nonFetchedIds.isEmpty else {
                return Promise<EventFetchResponse> { promise in
                    promise.reject(APIError.missingData)
            } }
            
            var fetchParam = EventFetchParam()
            fetchParam.providerIds = nonFetchedIds
            fetchParam.startTime = startTimeDate.milliSec
            fetchParam.endTime = endTimedate.milliSec
            let param = fetchParam.dictionary ?? [:]
            return service.fetchEvents(withParam: param, shouldRefresh: shouldRefresh, shouldLoadNext: shouldLoadNext)

        case let .byFetchParam(param):
            
            var tempParam = param
            
            if let ids = param.providerIds {
                
                guard !ids.isEmpty else {
                    return Promise<EventFetchResponse> { promise in
                        promise.reject(APIError.missingData)
                } }
                
                let start = Date(milliseconds: Int(param.startTime))
                let end = Date(milliseconds: Int(param.endTime))
                
                let nonFetchedIds = ids.filter { !FetchedDatesInfo.shared.areDatesAlreadyFetched(from: start, to: end, for: $0) }
                
                guard !nonFetchedIds.isEmpty else {
                    return Promise<EventFetchResponse> { promise in
                        promise.reject(APIError.missingData)
                } }

                tempParam.providerIds = nonFetchedIds
            }
            
            let paramDict = tempParam.dictionary ?? [:]
            return service.fetchEvents(withParam: paramDict, shouldRefresh: shouldRefresh, shouldLoadNext: shouldLoadNext)
        }
    }
    
    //Mehtods to delete the events from the local store
    //Clarify the need to provide access to these methods
    func deleteEventsFromLocalStore(action: LocalStorageDeleteAction) -> Promise<Void> {
        switch action {
        case let .eventWithKeys(keys):
            return service.deleteEventsFromLocalStore(withKeys: keys)
            
        case let .eventWithParentIds(parentIds):
            return service.deleteEventsFromLocalStore(withParentIds: parentIds)
            
        case let .eventWithCalendarIds(calendarIds):
            return service.deleteEventsFromLocalStore(withCalendarIds: calendarIds)
            
        case let .eventWithParentId(parentIds, afterDate):
            return service.deleteEventsFromLocalStore(withParentIds: parentIds, andAfter: afterDate)
            
        case let .parrentConfigurationWith(id):
            return service.deleteParrentConfigurationFromLocalStore(withId: id)
        }
    }
    func saveEvent(forResponse eventFetchResponse: EventFetchResponse?, shouldRefresh: Bool) -> Promise<EventFetchResponse> {
        return service.saveEvent(forResponse: eventFetchResponse, shouldRefresh: shouldRefresh)
    }
    func saveEvents(_ eventModels: [EventModel]) -> Promise<[EventModel]> {
        return service.saveEvents(eventModels)
    }
    func saveEvent(_ eventModel: EventModel?) -> Promise<EventModel> {
        return service.saveEvent(eventModel)
    }
    func updateResponse(forEvent eventId: String, withResponse responseStatus: ResponseStatus) -> Promise<EventModel> {
        service.updateResponse(forEvent: eventId, withResponse: responseStatus)
    }
}
