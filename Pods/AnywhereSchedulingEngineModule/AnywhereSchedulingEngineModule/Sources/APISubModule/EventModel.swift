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
    public var videoMeeting: String?
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
    case SetMore = "110003eb-76c1-4b81-a96a-4cdf91bf70fb"
    case Anytime = "0dab9518-34d4-4725-a847-ca7ff65168a2"
    case YoCoBoard = "d56194e1-b98b-4068-86f8-d442777d2a16"
    case AnytimeOld = "Anytime"
    case YoCoBoardOld = "YoCoBoard"
    case SetMoreOld = "SetMore"
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
//    public let metaData: JSONAny?
    
    public var notes: String?
    public let createdBy: String? // The user who created the event
    public let createdTime: Double?
    public let updatedTime: Double?
    
    public init(id: String, calendar: String, merchant: String, brand: AppBrand, type: FetchEventType?, provider: [String], service: [String], consumer: [String], resource: [String], startDateTime: String?, endDateTime: String?, startTime: Double, endTime: Double, maxSeats: Int, cost: Int, isExternal: Bool, isDeleted: Bool, rRule: String?, paymentStatus: String?, label: String?, bookingId: String?, source: String?, parentId: String?, title: String?, location: EventLocation?, notes: String?, createdBy: String?, createdTime: Double?, updatedTime: Double?) {
        self.id = id
        self.calendar = calendar
        self.merchant = merchant
        self.brand = brand
        self.type = type
                
        self.provider = provider
        self.service = service
        self.consumer = consumer
        self.resource = resource
        
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.startTime = startTime
        self.endTime = endTime
        
        self.maxSeats = maxSeats
        self.cost = cost
        self.isExternal = isExternal
        self.isDeleted = isDeleted

        self.rRule = rRule
        self.paymentStatus = paymentStatus
        self.label = label
        self.bookingId = bookingId
        self.source = source
        self.parentId = parentId
        self.title = title
        self.location = location

        self.notes = notes
        self.createdBy = createdBy
        self.createdTime = createdTime
        self.updatedTime = updatedTime
        
//        self.metaData = metaData
    }
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
//            metaData: self.metaData,
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
        self.isDeleted = event.isDeleted
        
        self.rRule = event.rRule
        self.paymentStatus = event.paymentStatus
        self.label = event.label
        self.bookingId = event.bookingId
        self.source = event.source
        self.parentId = event.parentId
        self.title = event.title
        
        if let eventLocation = event.location {
            self.location = EventLocation(videoMeeting: eventLocation)
        } else {
            self.location = nil
        }
        
        self.notes = event.notes
        self.createdBy = event.createdBy
        self.createdTime = event.createdTime
        self.updatedTime = event.updatedTime
        
//        self.metaData = JSONAny.initialize(fromJsonString: event.metaData ?? "")
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

// MARK: Encode/decode helpers

public class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
    
    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

public class JSONCodingKey: CodingKey {
    let key: String

    required public init?(intValue: Int) {
        return nil
    }

    required public init?(stringValue: String) {
        key = stringValue
    }

    public var intValue: Int? {
        return nil
    }

    public var stringValue: String {
        return key
    }
}

public class JSONAny: Codable {
    let value: Any
    
    var describingValue: String {
        return String(describing: value)
    }

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
