//
//  EventModel.swift
//  Anytime
//
//  Created by Monica on 24/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

enum EventSource: String, Codable {
    case businessPage
    case office365
    case google
    case setmore
//    case aw
//    case web
//    case ios
//    case localapp

    var image: UIImage? {
        switch self {
        case .office365:
            return AppDecor.Icons.Login.microsoft
        case .google:
            return AppDecor.Icons.Login.google
        case .setmore:
            return AppDecor.Icons.setmoreEvent
        default:
            return nil
        }
    }

    var isExternal: Bool {
        [.google, .setmore, .office365].contains(self)
    }
}

public enum AppBrand: String, Codable {
    case Anytime
    case YoCoBoard
    case SetMore
}

extension AppBrand {
    private var allowedBrands: [AppBrand] {
        [.Anytime, .SetMore]
    }

    var isAllowed: Bool {
        allowedBrands.contains(self)
    }
}

struct EventModel: Codable {
    let id: String
    let parentId: String?
    // Both values denote the account id for now
    let merchant: String
    let calendar: String

    var brand: AppBrand = .Anytime

    // milliseconds value for start and end time
    var startTime: Double
    var endTime: Double

    let maxSeats: Int
    let service: [String]
    var consumer: [String]
    var provider: [String]

    let resource: [String]

    var cost = 0
    var status: String? = "ACTIVE"

    //    let label: String?

    // for user reference
    let bookingId: String?

    //    let recurringId: String

    var source: String? = nil
    var type: String = "EVENT"
    //    let remainingSeats: Int?

    var isExternal: Bool = false
    var isDeleted: Bool = false

    var title: String? = ""
    let createdBy: String? // The user who created the event
    let location: EventLocation?
    var notes: String?

    let createdTime: Double?
    let updatedTime: Double?

    var startDateTime: String?
    var endDateTime: String?

    var rRule: String?
}

struct EventLocation: Codable {
    var teleport: String? // HAVE TO CONFIRM on why we are receiving an empty location
}

extension EventModel {
    init(fromEvent event: Event) {
        title = event.title
        id = event.id
        brand = AppBrand(rawValue: event.brand) ?? AppBrand.Anytime
        merchant = event.merchant
        calendar = event.calendar
        startTime = event.startTime
        endTime = event.endTime
        consumer = event.consumer
        provider = event.provider
        resource = event.resource
        service = event.service

        bookingId = event.bookingId
        cost = event.cost.intValue
        status = event.status
        type = event.type

        createdTime = event.createdTime
        updatedTime = event.updatedTime
        notes = event.notes
        startDateTime = event.startDateTime
        endDateTime = event.endDateTime
        createdBy = event.createdBy
        maxSeats = event.maxSeats.intValue
        isExternal = event.isExternal
        source = event.source
        if event.brand == "SetMore" {
            source = "setmore"
            isExternal = true
        }
//        if let source = event.source {
//         self.source = EventSource(rawValue: source)
//        }
        if let eventLocation = event.location {
            location = EventLocation(teleport: eventLocation)
        } else {
            location = nil
        }
        parentId = event.parentId

        guard !event.isExternal, let accpetedAttendees = event.confirmedAttendees, let declinedAttendees = event.cancelledAttendees, let pendingAttendees = event.pendingAttendees else {
            return
        }

        var attendees: [String: ResponseStatus] = [:]

        accpetedAttendees.forEach { id in
            attendees[id] = .accepted
        }

        declinedAttendees.forEach { id in
            attendees[id] = .declined
        }

        pendingAttendees.forEach { id in
            attendees[id] = .pending
        }

        rRule = event.rRule
    }
}

extension EventModel: Comparable {
    static func < (lhs: EventModel, rhs: EventModel) -> Bool {
        lhs.startTime < rhs.startTime
    }

    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension EventModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
