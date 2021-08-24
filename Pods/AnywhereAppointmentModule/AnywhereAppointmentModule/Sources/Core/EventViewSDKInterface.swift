//
//  Interface.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 07.08.2021.
//

import Foundation
import SwiftDate

public enum EventViewRoute {
    case createEvent(date: Date?)
    case updateEvent(event: Event?)
}

public class EventViewSDK {
    
    public static func updateATimezone(_ accountTimezoneId: String) {
        EventViewSDKConfiguration.current.accountTimezoneId = accountTimezoneId
    }
    
    public static func updatUser(_ user: User) {
        EventViewSDKConfiguration.current.user = user
    }
    
    public static func showEventView(eventViewRoute: EventViewRoute, user: User?, source: UIViewController) {
    
        let eventBaseNavigation = EventRouter.initialViewController
        guard let eventBaseView = eventBaseNavigation.topViewController as? EventBaseViewController else {
            fatalError("Event base navigation initialization failed!")
        }
        CustomFonts.loadFonts()
        
        if let user = user {
            EventViewSDKConfiguration.current.user = user
            EventViewSDKConfiguration.current.accountTimezoneId = user.timezone
        }
        
        switch eventViewRoute {
        case let .createEvent(chosenDate):
            if let date = chosenDate {
                eventBaseView.eventActionType = .create
                eventBaseView.selectedDate = date
                source.interactivelyPresent(eventBaseNavigation, animated: true, onCompletion: nil)
            }

        case let .updateEvent(updatingEvent):
            if let event = updatingEvent {
                eventBaseView.eventActionType = .update
                eventBaseView.viewModel?.event = event
                eventBaseView.viewMode = .full
                source.interactivelyPresent(eventBaseNavigation, animated: true, onCompletion: nil, shouldBeMaximized: true)
            }
        }
    }
}

struct EventViewSDKConfiguration {
    var user: User?
    
    var accountTimezoneId: String = TimeZone.current.identifier {
        didSet {
            guard accountTimezoneId.isNotEmpty else {
                preconditionFailure("Attempted to set empty value for timezone")
            }
            guard accountTimezoneId != oldValue, let userTimezone = TimeZone(identifier: accountTimezoneId) else {
                return
            }
            let region = Region(calendar: Calendar.current, zone: userTimezone, locale: Locale.autoupdatingCurrent)
            SwiftDate.defaultRegion = region
        }
    }
    
    static var current: EventViewSDKConfiguration = EventViewSDKConfiguration()
}

public struct Event {
    var id: String
    var merchant: String
    var calendar: String
    var brand: String
    var startTime: Double
    var endTime: Double
    var maxSeats: NSNumber
    var service: [String]
    var consumer: [String]
    var provider: [String] // The account user
    var resource: [String]
    var cost: NSNumber
    var status: String
    var source: String
    var bookingId: String
    var type: String
    var title: String
    var location: String?
    var createdTime: Double
    var updatedTime: Double
    var startDateTime: String
    var endDateTime: String
    var startDate: Date
    var notes: String
    var isExternal: Bool
    var parentId: String
    var createdBy: String?
    var rRule: String
   
    public init(id: String, merchant: String, calendar: String, brand: String, startTime: Double, endTime: Double, maxSeats: NSNumber, service: [String], consumer: [String], provider: [String], resource: [String], cost: NSNumber, status: String, source: String, bookingId: String, type: String, title: String, location: String?, createdTime: Double, updatedTime: Double, startDateTime: String, endDateTime: String, startDate: Date, notes: String, isExternal: Bool, parentId: String, createdBy: String?, rRule: String) {
        self.id = id
        self.merchant = merchant
        self.calendar = calendar
        self.brand = brand
        self.startTime = startTime
        self.endTime = endTime
        self.maxSeats = maxSeats
        self.service = service
        self.consumer = consumer
        self.provider = provider
        self.resource = resource
        self.cost = cost
        self.status = status
        self.source = source
        self.bookingId = bookingId
        self.type = type
        self.title = title
        self.location = location
        self.createdTime = createdTime
        self.updatedTime = updatedTime
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.startDate = startDate
        self.notes = notes
        self.isExternal = isExternal
        self.parentId = parentId
        self.createdBy = createdBy
        self.rRule = rRule
    }
}
public struct User {
    
    public init(id: String, type: String, branding: Bool, link: String, description: String, language: String, timezone: String, country: String, avatar: String, firstName: String, lastName: String, email: String, apiKey: String, user: String, account: String) {
        self.id = id
        self.type = type
        self.branding = branding
        self.link = link
        self.description = description
        self.language = language
        self.timezone = timezone
        self.country = country
        self.avatar = avatar
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.apiKey = apiKey
        self.user = user
        self.account = account
    }
    // MARK: IDs
    var id: String
    //    var userId: String // not required, reference for FULL CONTACT
    //    var accountId: String
    var type: String //change to use type
    
    var branding: Bool
    
    var link: String?
    
    var description: String?
    var language: String
    var timezone: String
    var country: String?
    var avatar: String?
    
    // MARK: User Infor
    var firstName: String?
    var lastName: String?
    var email: String?
    var apiKey: String?
    
    var user: String?
    var account: String?
    
    var fullName: String {
        guard let first = firstName?.trim() else {
            return ""
        }
        if let last = lastName?.trim() {
            return "\(first) \(last)"
        }
        return first
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        //        case userId
        //        case accountId
        case branding
        case type
        case link
        case description
        case country
        case language = "lang"
        case timezone
        case firstName
        case lastName
        case email = "login"
        case avatar
        case apiKey
        
        case user
        case account
    }
}
