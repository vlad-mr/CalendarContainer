//
//  Event.swift
//  Anytime
//
//  Created by Monica on 06/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import CoreData
import Foundation
import SwiftDate

@objc(Event)
public class Event: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var calendar: String
    @NSManaged public var merchant: String
    @NSManaged public var brand: String

    @NSManaged public var provider: [String]
    @NSManaged public var providerIdentifiers: String? // for predicate

    @NSManaged public var service: [String]
    @NSManaged public var consumer: [String]
    @NSManaged public var resource: [String]

    @NSManaged public var type: String
    @NSManaged public var startDateTime: String
    @NSManaged public var endDateTime: String

    @NSManaged public var startDate: Date // for predicate
    @NSManaged public var startTime: Double
    @NSManaged public var endTime: Double

    @NSManaged public var maxSeats: NSNumber
    @NSManaged public var cost: NSNumber
    @NSManaged public var rRule: String?
    @NSManaged public var isExternal: Bool
    @NSManaged public var paymentStatus: String?
    @NSManaged public var label: String?
    @NSManaged public var bookingId: String?
    @NSManaged public var source: String?
    @NSManaged public var parentId: String?
    @NSManaged public var title: String
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdBy: String?

//    @NSManaged public var metaData: [String: Any]?
    @NSManaged public var createdTime: Double
    @NSManaged public var updatedTime: Double

    @objc public func getEventDate() -> Date {
        return startTime.date.dateAt(.startOfDay)
    }

    public func setEvent(_ eventModel: EventModel) {
        id = eventModel.id
        calendar = eventModel.calendar
        merchant = eventModel.merchant
        brand = eventModel.brand.rawValue

        provider = eventModel.provider
        providerIdentifiers = provider.joined(separator: ";")

        service = eventModel.service
        consumer = eventModel.consumer
        resource = eventModel.resource

        type = eventModel.type!.rawValue
        startDateTime = eventModel.startDateTime!
        endDateTime = eventModel.endDateTime!

        startTime = eventModel.startTime
        endTime = eventModel.endTime
        startDate = startTime.date.dateAt(.startOfDay)

        maxSeats = NSNumber(value: eventModel.maxSeats)
        cost = NSNumber(value: eventModel.cost)

        isExternal = eventModel.isExternal

        rRule = eventModel.rRule
        paymentStatus = eventModel.paymentStatus
        label = eventModel.label
        bookingId = eventModel.bookingId
        source = eventModel.source
        parentId = eventModel.parentId
        title = eventModel.title ?? ""
        location = eventModel.location?.teleport
        notes = eventModel.notes
        createdBy = eventModel.createdBy

//        self.metaData = eventModel.metaData?.stuff ?? [:]
        createdTime = eventModel.createdTime!
        updatedTime = eventModel.updatedTime!
    }

    public func setEvent(_ meetingEvents: EventFetchResponse) {
        for event in meetingEvents.events {
            setEvent(event)
        }
    }
}
