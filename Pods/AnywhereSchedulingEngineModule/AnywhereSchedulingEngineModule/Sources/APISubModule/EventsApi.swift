//
//  EventsApi.swift
//  AnytimeAPI
//
//  Created by Monica on 24/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import Moya
import PromiseKit

enum EventsApi {
    case fetchAllEvents(withParam: [String: Any])
    case createEvent(_ eventInfo: [String: Any])
    case updateEvent(withParam: [String: Any])
    case updateInviteResponse(eventId: String, responseStatus: String)
    
    case createRecurring(withParam: [String: Any])
    case updateRecurringEvent(withParam: [String: Any])
    case fetchRecurring(withParam: [String: Any])
    case eventToRecurring(withParam: [String: Any])
    case recurringToEvent(withParam: [String: Any])
    case updateTail(withParam: [String: Any])
    
    case removeEvent(withParam: [String: Any])
}

extension EventsApi: TargetType {
    var baseURL: URL { Configuration.current.baseURL.appendingPathComponent(Configuration.current.apiVersion) }

    var path: String {
        switch self {
        case .fetchAllEvents, .createEvent, .updateEvent:
            return "/events"

        case .createRecurring, .updateRecurringEvent, .updateTail:
            return "/events"

        case .eventToRecurring, .recurringToEvent:
            return "/events"

        case .removeEvent:
            return "/events"

        case .updateInviteResponse(let eventId, let responseStatus):
            return "/event/pending/\(eventId)/\(responseStatus)"

        case .fetchRecurring:
            return "/recurring"
        }
    }

    var method: Moya.Method {
        switch self {

        case .fetchAllEvents:
            return .get

        case .createEvent, .updateEvent:
            return .post

        case .createRecurring, .updateRecurringEvent, .updateTail:
            return .post

        case .eventToRecurring, .recurringToEvent:
            return .post

        case .removeEvent:
            return .delete

        case  .updateInviteResponse:
            return .put

        case .fetchRecurring:
            return .get

        }
    }

    var sampleData: Data {
        switch self {

        case .createEvent(let param),
             .updateEvent(let param),
             .eventToRecurring(let param),
             .recurringToEvent(let param),
             .createRecurring(let param):
            
           let models = [
                (EventCreateParam.initialize(withDict: param)?.data.first)!
            ]
            
            let jsonData = SchedulingEngineApiResponse<[EventModel]>(
                response: true,
                data: models,
                error: nil,
                msg: nil)
            
            return jsonData.toJsonData!
            
        case .fetchAllEvents:
        let resp = EventFetchResponse(next_cursor: nil, events: [
            getEventModel(),
            getEventModel(),
            getEventModel()
        ])
        let jsonData = SchedulingEngineApiResponse<EventFetchResponse>(
            response: true,
            data: resp,
            error: nil,
            msg: nil)
            return jsonData.toJsonData!
        default:
            return Data()
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .fetchAllEvents(let param):
            var jsonStr: String = ""
            do {
                jsonStr = try ParameterEncodingHelper().convert(object: param)
            } catch {
                print("Cannot convert json string of event param", param)
            }
            return ["q": jsonStr]
        default:
            return [:]
        }
    }

    var task: Task {
        switch self {
        case .fetchAllEvents:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .createEvent(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .updateEvent(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)

        case .createRecurring(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .updateRecurringEvent(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .updateTail(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)

        case .eventToRecurring(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .recurringToEvent(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)

        case .removeEvent(let param):
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)

        case .updateInviteResponse:
            return .requestPlain
            
        case .fetchRecurring(let param):
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            guard let accessToken = Configuration.current.accessToken else { return nil }
            return ["Authorization": "Bearer \(accessToken)"]
        }
    }
}

public protocol EventsApiProtocol {
    func fetchEvents(withParam param: [String: Any]) -> Promise<Data>
    func createEvent(withParameters params: [String: Any]) -> Promise<Data>
    func updateEvent(withParameters params: [String: Any]) -> Promise<Data>
    func updateResponseStatus(withEventId eventId: String, andResponseStatus responseStatus: String) -> Promise<Data>
    func deleteEvent(withParameters params: [String: Any]) -> Promise<Data>
    
    func createRecurring(withParameters info: [String: Any]) -> Promise<Data>
    func getRecurring(withId id: String) -> Promise<Data>
    func updateRecurringEvent(withParameters params: [String: Any]) -> Promise<Data>
    
    func deleteRecurringEvent(withParameters params: [String: Any]) -> Promise<Data>
    func deleteRecurringTail(withParameters params: [String: Any]) -> Promise<Data>
    func eventToRecurring(withParameters params: [String: Any]) -> Promise<Data>
    func recurringToEvent(withParameters params: [String: Any]) -> Promise<Data>
    func updateTail(withParameters params: [String: Any]) -> Promise<Data>
}

class EventsApiService: BaseApiProvider, EventsApiProtocol {
    
    private(set) var provider: MoyaProvider<EventsApi>
    
    init(provider: MoyaProvider<EventsApi> = MoyaProvider<EventsApi>()) {
        self.provider = provider
    }
    
    // MARK: - Fetch Events
    func fetchEvents(withParam param: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.fetchAllEvents(withParam: param)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                
                
                
                
                promise.fulfill(data)
            }
        }
    }
    
    func getRecurring(withId id: String) -> Promise<Data> {
        let param = ["ids": [id]].dictionary ?? [:]

        return Promise<Data> { promise in
            provider.request(.fetchRecurring(withParam: param)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    // MARK: - Create Events
    func createEvent(withParameters info: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.createEvent(info)) {
                let response = self.handleResponse($0)
                guard let data = self.handleResponse($0).data else {
                    promise.reject(response.error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    func createRecurring(withParameters info: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.createRecurring(withParam: info)) {
                let response = self.handleResponse($0)
                guard let data = self.handleResponse($0).data else {
                    promise.reject(response.error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    // MARK: - Update Events
    func updateEvent(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.updateEvent(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    func updateTail(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.updateTail(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    func updateRecurringEvent(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.updateRecurringEvent(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    func updateResponseStatus(withEventId eventId: String, andResponseStatus responseStatus: String) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.updateInviteResponse(eventId: eventId, responseStatus: responseStatus)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    // MARK: - Changing the type of event(Recurring -> Event)
    func recurringToEvent(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.recurringToEvent(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    // MARK: - Changing the type of event(Event -> Recurring)
    func eventToRecurring(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.eventToRecurring(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
    
    // MARK: - Delete Events for action type
    func deleteEvent(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.removeEvent(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }

    func deleteRecurringEvent(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.removeEvent(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }

    func deleteRecurringTail(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.removeEvent(withParam: params)) {
                guard let data = self.handleResponse($0).data else {
                    promise.reject(self.handleResponse($0).error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
}

extension EventsApi {
    func getEventModel() -> EventModel {
        let appUserId = UUID().uuidString
        let accountId = UUID().uuidString
        
        let defaultEvent = EventModel(id: UUID().uuidString, calendar: UUID().uuidString, merchant: accountId, brand: .Anytime, type: .event, provider: [], service: [], consumer: [], resource: [], startDateTime: nil, endDateTime: nil, startTime: 0, endTime: 0, maxSeats: 0, cost: 0, isExternal: false, isDeleted: false, rRule: nil, paymentStatus: nil, label: nil, bookingId: nil, source: nil, parentId: nil, title: nil, location: nil, notes: nil, createdBy: appUserId, createdTime: 123, updatedTime: 1233)
        return defaultEvent
    }
}

