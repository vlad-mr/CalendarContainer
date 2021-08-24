//
//  ContactMode.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 07.08.2021.
//

import Foundation
import SwiftyBeaver

public let Logger = SwiftyBeaver.self

func configureLogger() {
    let console = ConsoleDestination()
    console.format = "$C$L$c $N.$F():$l - $M $C$c"

    console.levelColor.verbose = "🔷 🔷 "
    console.levelColor.debug = "🔰 🔰 "
    console.levelColor.info = "🍭 🍭 "
    console.levelColor.warning = "⚠️ ⚠️ "
    console.levelColor.error = "⛔️ ⛔️ "

    Logger.addDestination(console)

    #if RELEASE
        console.minLevel = .error
    #endif
}

enum EventActionType: String, Codable {
    case create = "EVENT_CREATE"
    case update = "EVENT_UPDATE"

    case recurringCreate = "RECURRING_CREATE"
    case recurringUpdate = "RECURRING_UPDATE"
    case tail = "TAIL"
    case recurringToEvent = "RECURRING_TO_EVENT"
    case eventToRecurring = "EVENT_TO_RECURRING"
}

enum ResponseStatus: String, Codable, Equatable {
    case accepted
    case pending = "needsAction"
    case declined
    case tentative
}

public extension TimeZone {
    /**
     This method returns a string specifying the time difference from GMT

     - parameter forDate: (Optional) The date for which the string is required.

     - Returns: A string in the format 'GMT+/-HH:DD'

     */
    func displayStringFromGMT(forDate date: Date = Date()) -> String {
        let hoursFromGMT = secondsFromGMT(for: date) / 3600
        let minutesFromGMT = secondsFromGMT(for: date) / 60 % 60
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
        let gmtValue = displayStringFromGMT(forDate: date)
        let localizedName = self.localizedName(for: .standard, locale: .current) ?? ""
        let cityName = identifier.split(separator: "/").last ?? ""

        let displayName = "\(localizedName),\n\(cityName), (\(gmtValue))"
        return displayName
    }
}
