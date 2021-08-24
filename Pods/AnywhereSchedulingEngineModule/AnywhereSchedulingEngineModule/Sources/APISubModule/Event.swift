//
//  Event.swift
//  Anytime
//
//  Created by Monica on 06/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import CoreData
import SwiftDate

@objc(Event)
public class Event: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var calendar: String
    @NSManaged public var merchant: String
    @NSManaged public var brand: String

    @NSManaged public var provider: [String]
    @NSManaged public var providerIdentifiers: String? //for predicate

    @NSManaged public var service: [String]
    @NSManaged public var consumer: [String]
    @NSManaged public var resource: [String]

    @NSManaged public var type: String
    @NSManaged public var startDateTime: String
    @NSManaged public var endDateTime: String
    
    @NSManaged public var startDate: Date //for predicate
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
    
    @NSManaged public var metaData: String?
    @NSManaged public var createdTime: Double
    @NSManaged public var updatedTime: Double

    @objc public func getEventDate() -> Date {
        return startTime.date.dateAt(.startOfDay)
    }

    public func setEvent(_ eventModel: EventModel) {
        
        self.id = eventModel.id
        self.calendar = eventModel.calendar
        self.merchant = eventModel.merchant
        self.brand = eventModel.brand.rawValue
        
        self.provider = eventModel.provider
        self.providerIdentifiers = provider.joined(separator: ";")

        self.service = eventModel.service
        self.consumer = eventModel.consumer
        self.resource = eventModel.resource

        self.type = eventModel.type!.rawValue
        self.startDateTime = eventModel.startDateTime!
        self.endDateTime = eventModel.endDateTime!
        
        self.startTime = eventModel.startTime
        self.endTime = eventModel.endTime
        self.startDate = startTime.date.dateAt(.startOfDay)

        self.maxSeats = NSNumber(value: eventModel.maxSeats)
        self.cost = NSNumber(value: eventModel.cost)
        
        self.isExternal = eventModel.isExternal
        
        self.rRule = eventModel.rRule
        self.paymentStatus = eventModel.paymentStatus
        self.label = eventModel.label
        self.bookingId = eventModel.bookingId
        self.source = eventModel.source
        self.parentId = eventModel.parentId
        self.title = eventModel.title ?? ""
        self.location = eventModel.location?.teleport
        self.notes = eventModel.notes
        self.createdBy = eventModel.createdBy

        self.metaData = eventModel.metaData?.describingValue
        self.createdTime = eventModel.createdTime!
        self.updatedTime = eventModel.updatedTime!
    }

    public func setEvent(_ meetingEvents: EventFetchResponse) {
        for event in meetingEvents.events {
            self.setEvent(event)
        }
    }
}
