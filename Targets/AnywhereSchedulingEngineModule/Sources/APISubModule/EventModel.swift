//
//  EventModel.swift
//  Anytime
//
//  Created by Monica on 24/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

// MARK: - DataClass
public struct ParrentConfigClass: Codable {
    let response: Bool
    let data: [EventModel]
}

public enum ResponseStatus: String, Codable, Equatable {
    case accepted
    case pending = "needsAction"
    case declined
    case tentative
}

public struct EventFetchResponse: Codable {
    public let next_cursor: String?
    public let events: [EventModel]
    
    public init(next_cursor: String?, events: [EventModel]) {
        self.next_cursor = next_cursor
        self.events = events
    }
}
public extension EventFetchResponse {
    static var empty: EventFetchResponse { EventFetchResponse(next_cursor: nil, events: []) }
}

public struct EventLocation: Codable {
    public var teleport: String? // HAVE TO CONFIRM on why we are receiving an empty location
}

public enum EventSource: String, Codable {
    case businessPage
    case office365
    case google
    case setmore
    //    case aw
    //    case web
    //    case ios
    //    case localapp
    
    // TODO: Place `var image` to extension
    //    var image: UIImage? {
    //        switch self {
    //
    //        case .office365:
    //            return AppDecor.Icons.Login.microsoft
    //        case .google:
    //            return AppDecor.Icons.Login.google
    //        case .setmore:
    //            return AppDecor.Icons.setmoreEvent
    //        default:
    //            return nil
    //        }
    //    }
    
    var isExternal: Bool {
        [.google, .setmore, .office365].contains(self)
    }
}

public enum AppBrand: String, Codable {
    case Anytime
    case YoCoBoard
    case SetMore
}

public extension AppBrand {
    
    private var allowedBrands: [AppBrand] {
        [.Anytime, .SetMore]
    }
    
    var isAllowed: Bool {
        allowedBrands.contains(self)
    }
}

public struct EventModel: Codable {

    public let id: String
    public let calendar: String
    public let merchant: String
    public var brand: AppBrand
    public var type: FetchEventType? = .event

    public var provider: [String]
    public let service: [String]
    public var consumer: [String]
    public let resource: [String]

    public var startDateTime: String?
    public var endDateTime: String?

    public var startTime: Double // milliseconds value for start and end time
    public var endTime: Double // milliseconds value for start and end time
    public let maxSeats: Int
    public var cost = 0
    public var isExternal: Bool = false
    public var isDeleted: Bool = false
    public var rRule: String?
    public var paymentStatus: String?
    public var label: String?
    public let bookingId: String?     // for user reference
    public var source: String?
    public var parentId: String?
    public var title: String? = ""

    public let location: EventLocation?
//    public let metaData: MetaData?
    
    public var notes: String?
    public let createdBy: String? // The user who created the event
    public let createdTime: Double?
    public let updatedTime: Double?
}

public extension EventModel {
    func swapID() -> EventModel {
        return .init(
            id: self.parentId ?? "",
            calendar: self.calendar,
            merchant: self.merchant,
            brand: self.brand,
            type: self.type,
            provider: self.provider,
            service: self.service,
            consumer: self.consumer,
            resource: self.resource,
            startDateTime: self.startDateTime,
            endDateTime: self.endDateTime,
            startTime: self.startTime,
            endTime: self.endTime,
            maxSeats: self.maxSeats,
            cost: self.cost,
            isExternal: self.isExternal,
            isDeleted: self.isDeleted,
            rRule: self.rRule,
            paymentStatus: self.paymentStatus,
            label: self.label,
            bookingId: self.bookingId,
            source: self.source,
            parentId: nil,
            title: self.title,
            location: self.location,
            notes: self.notes,
            createdBy: self.createdBy,
            createdTime: self.createdTime,
            updatedTime: self.updatedTime)
    }
        
    init(fromEvent event: Event) {
        self.id = event.id
        self.calendar = event.calendar
        self.merchant = event.merchant
        self.brand = AppBrand(rawValue: event.brand) ?? AppBrand.Anytime
        self.type = FetchEventType(rawValue: event.type) ?? FetchEventType.event
                
        self.provider = event.provider
        self.service = event.service
        self.consumer = event.consumer
        self.resource = event.resource
        
        self.startDateTime = event.startDateTime
        self.endDateTime = event.endDateTime
        self.startTime = event.startTime
        self.endTime = event.endTime
        
        self.maxSeats = event.maxSeats.intValue
        self.cost = event.cost.intValue
        self.isExternal = event.isExternal
//        self.isDeleted = event.isDeleted
        
        self.rRule = event.rRule
        self.paymentStatus = event.paymentStatus
        self.label = event.label
        self.bookingId = event.bookingId
        self.source = event.source
        self.parentId = event.parentId
        self.title = event.title
        
        if let eventLocation = event.location {
            self.location = EventLocation(teleport: eventLocation)
        } else {
            self.location = nil
        }
        
        self.notes = event.notes
        self.createdBy = event.createdBy
        self.createdTime = event.createdTime
        self.updatedTime = event.updatedTime
    }
}

extension EventModel: Comparable {
    public static func < (lhs: EventModel, rhs: EventModel) -> Bool {
        lhs.startTime < rhs.startTime
    }
    
    public static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension EventModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//public struct MetaData: Codable {
//    var stuff: [String: Any]?
//
//    init(dict: [String: Any] = [:]) {
//        self.stuff = dict
//    }
//
//    private struct MetaDataCodingKeys: CodingKey {
//        var stringValue: String
//        init?(stringValue: String) { self.stringValue = stringValue }
//
//        var intValue: Int?
//        init?(intValue: Int) { return nil }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: MetaDataCodingKeys.self)
//
//        for item in stuff! {
//            if let value = item.value as? String {
//                try? container.encode(value, forKey: KeyedEncodingContainer<MetaDataCodingKeys>.Key(stringValue: item.key)!)
//            } else if let value = item.value as? Bool {
//                try? container.encode(value, forKey: KeyedEncodingContainer<MetaDataCodingKeys>.Key(stringValue: item.key)!)
//            } else if let value = item.value as? Int {
//                try? container.encode(value, forKey: KeyedEncodingContainer<MetaDataCodingKeys>.Key(stringValue: item.key)!)
//            } else if let value = item.value as? Double {
//                try? container.encode(value, forKey: KeyedEncodingContainer<MetaDataCodingKeys>.Key(stringValue: item.key)!)
//            } else if let value = item.value as? Float {
//                try? container.encode(value, forKey: KeyedEncodingContainer<MetaDataCodingKeys>.Key(stringValue: item.key)!)
//            } else {
//                print("MetaData Decoder Err ")
//            }
//        }
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try! decoder.container(keyedBy: MetaDataCodingKeys.self)
//        var data = [String: Any]()
//
//        for key in container.allKeys {
//            if let value = try? container.decode(String.self, forKey: key) {
//                data[key.stringValue] = value
//            } else if let value = try? container.decode(Bool.self, forKey: key) {
//                data[key.stringValue] = value
//            } else if let value = try? container.decode(Int.self, forKey: key) {
//                data[key.stringValue] = value
//            } else if let value = try? container.decode(Double.self, forKey: key) {
//                data[key.stringValue] = value
//            } else if let value = try? container.decode(Float.self, forKey: key) {
//                data[key.stringValue] = value
//            } else {
//                print("MetaData Decoder Err \(key.stringValue)")
//            }
//        }
//        self.stuff = data
//    }
//}
