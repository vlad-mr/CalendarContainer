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
    case updateEvent(event: EventModel?)
}

public enum PresentationMode {
    case full
    case interactively(shouldBeMaximized: Bool)
}

public protocol AppointmentDelegate: class {
    func delete(event: EventModel, forActionType actionType: EventDeleteActionType, completion: @escaping (Swift.Result<String, Error>) -> Void)
    func actionFor(event: EventModel, withActionType actionType: EventActionType, completion: @escaping (Swift.Result<String, Error>) -> Void)
}

public class EventViewSDK {
    
    public static func updateATimezone(_ accountTimezoneId: String) {
        EventViewSDKConfiguration.current.accountTimezoneId = accountTimezoneId
    }
    
    public static func updatUser(_ user: User) {
        EventViewSDKConfiguration.current.user = user
    }
    
    public static func configurePlugIn(withBrand brand: AppBrand, user: User?) {
        if let user = user {
            EventViewSDKConfiguration.current.user = user
            EventViewSDKConfiguration.current.accountTimezoneId = user.timezone
        } else {
            let testingUser = User(
                id: UUID().uuidString,
                type: "",
                branding: false,
                link: "",
                description: "",
                language: "",
                timezone: TimeZone.current.identifier,
                country: "",
                avatar: "",
                firstName: "",
                lastName: "",
                email: "",
                apiKey: "",
                user: "",
                account: UUID().uuidString)
            EventViewSDKConfiguration.current.user = testingUser
            EventViewSDKConfiguration.current.accountTimezoneId = testingUser.timezone
        
        }
        
        EventViewSDKConfiguration.current.appBrand = brand
        CustomFonts.loadFonts()
    }
    
    public static func showEventView(eventViewRoute: EventViewRoute, source: UIViewController, delegate: AppointmentDelegate, presentationMode: PresentationMode) {
    
        let eventBaseNavigation = EventRouter.initialViewController
        guard let eventBaseView = eventBaseNavigation.topViewController as? EventBaseViewController else {
            fatalError("Event base navigation initialization failed!")
        }
        eventBaseView.viewModel?.appointmentDelegate = delegate
        
        switch eventViewRoute {
        case let .createEvent(chosenDate):
            if let date = chosenDate {
                eventBaseView.eventActionType = .create
                eventBaseView.selectedDate = date
                self.present(vc: eventBaseNavigation, from: source, with: presentationMode)
//                source.interactivelyPresent(eventBaseNavigation, animated: true, onCompletion: nil)
            }

        case let .updateEvent(updatingEvent):
            if let event = updatingEvent {
                eventBaseView.eventActionType = .update
                eventBaseView.viewModel?.originalEventModel = event
                eventBaseView.viewMode = .full
                self.present(vc: eventBaseNavigation, from: source, with: presentationMode)
//                source.interactivelyPresent(eventBaseNavigation, animated: true, onCompletion: nil, shouldBeMaximized: true)
            }
        }
    }
    private static func present(vc: UIViewController,from source: UIViewController, with mode: PresentationMode) {
        switch mode {
        case .full:
            source.present(vc, animated: true, completion: nil)

        case .interactively(let shouldBeMaximized):
            source.interactivelyPresent(vc, animated: true, onCompletion: nil, shouldBeMaximized: shouldBeMaximized)
        }
    }
}

struct EventViewSDKConfiguration {
    var user: User?
    var appBrand: AppBrand?
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

public extension TimeZone {

    /**
     This method returns a string specifying the time difference from GMT

     - parameter forDate: (Optional) The date for which the string is required.

     - Returns: A string in the format 'GMT+/-HH:DD'

     */
    func displayStringFromGMT(forDate date: Date = Date()) -> String {

        let hoursFromGMT = self.secondsFromGMT(for: date) / 3600
        let minutesFromGMT = self.secondsFromGMT(for: date) / 60 % 60
        guard hoursFromGMT >= 0 else {
            guard hoursFromGMT <= -10 else {
                return "GMT-0\(-hoursFromGMT):\(minutesFromGMT == 0 ? "00" : "\(-minutesFromGMT)")"
            }
            return "GMT-\(-hoursFromGMT):\(minutesFromGMT == 0 ? "00" : "\(-minutesFromGMT)")"
        }
        guard hoursFromGMT >= 10 else {
            return "GMT+0\(hoursFromGMT):\(minutesFromGMT == 0 ? "00" : "\(minutesFromGMT)")"
        }
        return "GMT+\(hoursFromGMT):\(minutesFromGMT == 0 ? "00" : "\(minutesFromGMT)")"
    }

    func displayName(forDate date: Date = Date()) -> String {

        let gmtValue = self.displayStringFromGMT(forDate: date)
        let localizedName = self.localizedName(for: .standard, locale: .current) ?? ""
        let cityName = self.identifier.split(separator: "/").last ?? ""

        let displayName = "\(localizedName),\n\(cityName), (\(gmtValue))"
        return displayName
    }
}

//MOdels
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

public enum ResponseStatus: String, Codable, Equatable {
    case accepted
    case pending = "needsAction"
    case declined
    case tentative
}

public enum FetchEventType: String, Codable {
    case appointment = "APPOINTMENT"
    case event = "EVENT"
    case groupe = "GROUP"
    case offhours = "OFFHOURS"
    case session = "SESSION"
    case reminder = "REMINDER"
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

public struct EventLocation: Codable {
    public var videoMeeting: String?
    
    public init(videoMeeting: String?) {
        self.videoMeeting = videoMeeting
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
