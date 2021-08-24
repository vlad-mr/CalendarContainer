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
    public let bookingId: String? // for user reference
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
            id: parentId ?? "",
            calendar: calendar,
            merchant: merchant,
            brand: brand,
            type: type,
            provider: provider,
            service: service,
            consumer: consumer,
            resource: resource,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            startTime: startTime,
            endTime: endTime,
            maxSeats: maxSeats,
            cost: cost,
            isExternal: isExternal,
            isDeleted: isDeleted,
            rRule: rRule,
            paymentStatus: paymentStatus,
            label: label,
            bookingId: bookingId,
            source: source,
            parentId: nil,
            title: title,
            location: location,
            notes: notes,
            createdBy: createdBy,
            createdTime: createdTime,
            updatedTime: updatedTime
        )
    }

    init(fromEvent event: Event) {
        id = event.id
        calendar = event.calendar
        merchant = event.merchant
        brand = AppBrand(rawValue: event.brand) ?? AppBrand.Anytime
        type = FetchEventType(rawValue: event.type) ?? FetchEventType.event

        provider = event.provider
        service = event.service
        consumer = event.consumer
        resource = event.resource

        startDateTime = event.startDateTime
        endDateTime = event.endDateTime
        startTime = event.startTime
        endTime = event.endTime

        maxSeats = event.maxSeats.intValue
        cost = event.cost.intValue
        isExternal = event.isExternal
//        self.isDeleted = event.isDeleted

        rRule = event.rRule
        paymentStatus = event.paymentStatus
        label = event.label
        bookingId = event.bookingId
        source = event.source
        parentId = event.parentId
        title = event.title

        if let eventLocation = event.location {
            location = EventLocation(teleport: eventLocation)
        } else {
            location = nil
        }

        notes = event.notes
        createdBy = event.createdBy
        createdTime = event.createdTime
        updatedTime = event.updatedTime
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

// public struct MetaData: Codable {
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
// }
