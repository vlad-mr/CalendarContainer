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

public enum EventViewSDK {
    public static func updateATimezone(_ accountTimezoneId: String) {
        EventViewSDKConfiguration.current.accountTimezoneId = accountTimezoneId
    }

    public static func updatUser(_ user: User) {
        EventViewSDKConfiguration.current.user = user
    }

    public static func getEventView(viewMode: ViewMode, eventViewRoute: EventViewRoute, user: User?, accountTimezoneId: String?) -> EventBaseNavigationController {
        let eventBaseNavigation = EventRouter.initialViewController
        guard let eventBaseView = eventBaseNavigation.topViewController as? EventBaseViewController else {
            fatalError("Event base navigation initialization failed!")
        }

        eventBaseView.viewMode = viewMode

        if let user = user {
            EventViewSDKConfiguration.current.user = user
        }

        if let timezoneId = accountTimezoneId {
            EventViewSDKConfiguration.current.accountTimezoneId = timezoneId
        }

        switch eventViewRoute {
        case let .createEvent(chosenDate):
            if let date = chosenDate {
                eventBaseView.eventActionType = .create
                eventBaseView.selectedDate = date
            }
            return eventBaseNavigation

        case let .updateEvent(updatingEvent):
            if let event = updatingEvent {
                eventBaseView.eventActionType = .update
                eventBaseView.viewModel?.event = event
                eventBaseView.viewMode = .full
            }

            return eventBaseNavigation
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

    static var current = EventViewSDKConfiguration()
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
    var cancelledAttendees: [String]?
    var confirmedAttendees: [String]?
    var pendingAttendees: [String]?
    var organizers: [String]
    var isOrganizer: Bool
    var linkedEmail: String
    var rRule: String
}

public struct User {
    // MARK: IDs

    var id: String
    //    var userId: String // not required, reference for FULL CONTACT
    //    var accountId: String
    var type: String // change to use type

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
